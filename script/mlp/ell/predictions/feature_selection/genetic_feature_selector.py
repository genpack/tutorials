import logging
import math
import os
import time
from copy import deepcopy
from typing import Dict, List, Optional, Tuple

import numpy as np
import pandas as pd
from ell.env.env_abc import AbstractEnv
from ell.env.uri import URI
from pandas import DataFrame

from ell.predictions import compat, utils
from ell.predictions.errors import DistributorException, DistributorComputeBudgetExhausted
from ell.predictions.distributing import AbstractDistributor

LOGGER = logging.getLogger(__name__)

NUM_SUBMISSION_ATTEMPTS = 3


def genetic_feature_selector(
    config: dict, distributor: AbstractDistributor, module_path: URI, env: AbstractEnv = compat.env
):
    """Performs a greedy subset scorer run using the provided config and distributor.

    Builds a feature importance score for each feature by training random subsets
    of features and determining the effect on the accuracy of the model of leaving out
    features. This is the greedy algorithm which keeps the best model.

    In greedy subset scorer, best models of each batch are boosted by
    removing features with zero importance and adding
    random subsets from the remaining
    features excluding features by which the best model is trained with.
    The boosted models are trained in the following batch.
    If in any step, the new model came up with higher performance than the best
    model, it replaces the best model.

    Args:
        config:
        distributor:
        module_path:
        env:

    """
    executor_path = utils.ensure_uri(
        os.path.dirname(module_path.rstrip(r"\/")), is_folder=True
    )

    # Set defaults for the feature selection settings:
    fs_config = config.pop("feature_selection")
    fs_config["num_batches"] = fs_config.get("num_batches", 20)
    fs_config["batch_size"] = fs_config.get("batch_size", 1)
    fs_config["subset_size"] = fs_config.get("subset_size", 0.2)
    fs_config["metric"] = fs_config.get("metric", "gini_coefficient")
    fs_config["remove_zif"] = fs_config.get("remove_zero_importance_features", False)
    fs_config["maximise"] = fs_config.get("maximise", True)
    fs_config["score_aggregator"] = fs_config.get("score_aggregator", "max")
    fs_config["robustness_aggregator"] = fs_config.get("robustness_aggregator", "mean")
    fs_config["sample_sets"] = fs_config.get("sample_sets", [])
    fs_config["selection_mode"] = fs_config.get("selection_mode", "robust")

    # If early_stopping is not specified in the config then it is not required
    fs_config["early_stopping"] = fs_config.get("early_stopping", math.inf)
    fs_config["initial_features"] = fs_config.get("initial_features", [])
    # fs_config['cutpoint'] = fs_config.get("cutpoint", 0.0)
    fs_config["num_top_models"] = fs_config.get("num_top_models", 1)

    fs_config["subset_size"] = int(
        len(config["model"]["features"]) * fs_config["subset_size"]
    )
    LOGGER.info(
        "Performing experiments in {} features".format(fs_config["subset_size"])
    )

    output = None
    compute_budget_exc = None
    if len(fs_config["initial_features"]) == 0:
        fake_features = ["fake_feature"]
        fake_importance = 0.0
    else:
        fake_features = fs_config["initial_features"]
        fake_importance = 1.0

    fset_id = -1
    for i in range(fs_config["num_top_models"]):
        if fs_config["selection_mode"] == "robust":
            fset_id += 1
            # fset_id: str(uuid.uuid4())[0:8]
        for test_date in fs_config["sample_sets"]:
            if fs_config["selection_mode"] != "robust":
                fset_id += 1
                # fset_id: str(uuid.uuid4())[0:8]
            fake = pd.DataFrame(
                {
                    "feature_name": fake_features,
                    "importance": fake_importance,
                    "gini_coefficient": 0.0,
                    "lift_2": 0.0,
                    "precision_2": 0.0,
                    "module_id": "fake_module_id" + "_" + str(i) + "_" + test_date,
                    "feature_set_id": "FS" + str(fset_id),
                    "batch_number": 0,
                    "test_date": test_date,
                }
            )
            output = pd.concat([output, fake], axis=0)

    log_data = {"selected_models": [], "num_unsuccessful_trials": 0}
    batch_number = 0
    while (batch_number < fs_config["num_batches"]) and (
        log_data["num_unsuccessful_trials"] < fs_config["early_stopping"]
    ):
        batch_number += 1
        LOGGER.info(
            "Starting batch {} out of {}:".format(
                batch_number, fs_config["num_batches"]
            )
        )

        batch_configs, log_data = _create_batch(
            settings=fs_config, raw_scores=output, config=config, log_data=log_data
        )

        collected, runids, experiments, compute_budget_exc = _run_batch(
            distributor, batch_configs
        )

        LOGGER.info("Run batch result: %s", collected)

        batch_output, experiments = _collect_batch(
            features=config["model"]["features"],
            collected=collected,
            runids=runids,
            experiments=experiments,
            metric=fs_config["metric"],
            batch_number=batch_number,
            executor_path=executor_path,
            env=env,
        )
        LOGGER.debug(
            "Experiments after collecting batch %s: %s", batch_number, experiments
        )

        # # Pick the best model
        # (
        #     best_experiment,
        #     remaining_features,
        #     used_features,
        #     num_unsuccessful_trials,
        # ) = _update_best_experiment(
        #     batch_number,
        #     batch_output,
        #     experiments,
        #     best_experiment,
        #     features,
        #     remaining_features,
        #     num_unsuccessful_trials,
        #     settings=fs_config,
        # )

        output = output.append(batch_output)
        output = output[output.batch_number > 0]

        if compute_budget_exc:
            LOGGER.warning(
                "Greedy Subset Scorer ran out of compute budget in batch %s",
                batch_number,
            )
            break

        if compute_budget_exc:
            LOGGER.warning(
                "Greedy Subset Scorer ran out of compute budget during batch number %s",
                batch_number,
            )
            break

        feature_scores = _aggregation(raw_scores=output, settings=fs_config)
        _save(feature_scores, output, module_path)

    LOGGER.info("Finished Greedy Subset Scorer")

    if compute_budget_exc:
        raise DistributorComputeBudgetExhausted(
            "Greedy Subset Scorer could not distribute all jobs"
        ) from compute_budget_exc

    return feature_scores, output


def _get_best_models(raw_scores, settings):
    # Pick best models from raw scores:
    raw_scores = raw_scores.sort_values(settings["metric"], ascending=False)
    model_profile = raw_scores.drop_duplicates(subset="module_id", keep="first")
    if settings["selection_mode"] == "global":
        selected_models = model_profile[
            0:min(model_profile.shape[0], settings["num_top_models"])
        ]
    elif settings["selection_mode"] == "isolate":
        selected_models = model_profile.groupby("test_date").apply(
            lambda s: s[0:settings["num_top_models"]]
        )
    elif settings["selection_mode"] == "robust":
        selected_fsets = model_profile.groupby("feature_set_id").agg(
            {settings["metric"]: settings["robustness_aggregator"]}
        )
        selected_fsets = selected_fsets.sort_values(settings["metric"], ascending=False)
        selected_models = model_profile[
            model_profile.feature_set_id.isin(
                selected_fsets.index[0: settings["num_top_models"]]
            )
        ]
    else:
        raise ValueError(
            "Unknown selection_mode '{}'".format(settings["selection_mode"])
        )

    return selected_models


def _generate_feature_set(existing_features, features_left, num_new_features):
    subset = list(
        np.random.choice(
            features_left, min(num_new_features, len(features_left)), replace=False
        )
    )
    return list(set(subset + existing_features))


def _create_batch(
    raw_scores: pd.DataFrame, config: Dict, settings: Dict, log_data: Dict
) -> Tuple[List[Dict], Dict]:

    """Creates a list of configs for the batch to run
    Args:
        raw_scores: table of raw scores containing the feature importances of all child models in a melted format

        config: prediction config for the batch jobs. Features will be overwritten.

        settings:
            Dictionary containing feature selection settings. The following keys will be used:
                batch_size: batch size as specified in the config file.
                subset_size: should be a value between 0 and 1 specifying the subset size as
                    percentage of total number of features.
                used_features: list of used features of the best model to be added to the
                    randomly picked new subset of features.
                remaining_features: list of features from which a random subset is chosen.
            selection_mode: must be one of the two options `robust` or `global` .
                if set to `robust`, features of all ``test_dates`` will be the same
                (each random set of features will be tested on every sample set)
                and the best model of each batch is the model
                with the highest aggregated performance over all the sample sets specified in ``test_dates``
                if set to `global` feature sets of all child models in the batch are different.
                the model with the best absolute performance over the entire batch
                is picked as the best model

        log_data: a dictionary containing two keys:
            num_unsuccessful_trials: number of consequensive unsuccessful batches.
            An unsuccesssful batch run is a batch run that has
            failed to boost any of the selected top models in the previous batch.

    Returns:
        list of configs returned for the batch
    """

    configs = []

    selected_models = _get_best_models(raw_scores=raw_scores, settings=settings)

    if set(selected_models.module_id) == set(log_data["selected_models"]):
        log_data["num_unsuccessful_trials"] += 1
    else:
        log_data["selected_models"] = selected_models.module_id

    fset_ids = list(set(selected_models.feature_set_id))

    num_models = max(1, selected_models.shape[0])

    loop_size = int(settings["batch_size"] / num_models)

    for i in range(loop_size):
        generated = dict()
        for fset_id in fset_ids:
            used_features = raw_scores[
                (raw_scores.feature_set_id == fset_id) & (raw_scores.importance > 0)
            ]
            used_features = list(set(used_features["feature_name"]))
            remaining_features = _set_diff(config["model"]["features"], used_features)
            generated[fset_id] = _generate_feature_set(
                used_features, remaining_features, settings["subset_size"]
            )

        for j in range(num_models):
            new_config = deepcopy(config)

            new_config["model"]["features"] = generated[
                list(selected_models.feature_set_id)[j]
            ]
            # new_config["feature_set_id"] = new_fset_id[selected_models.feature_set_id[j]]
            new_config["feature_set_id"] = (
                list(selected_models.feature_set_id)[j] + "b" + str(i + 1)
            )
            new_config["boosted_module_id"] = list(selected_models.module_id)[j]
            new_config["train"] = "train_" + list(selected_models.test_date)[j]
            new_config["test"] = "test_" + list(selected_models.test_date)[j]

            configs.append(new_config)

    return configs, log_data


def _run_batch(
    distributor: AbstractDistributor, configs: List[Dict]
) -> Tuple[
    Dict[str, Dict], List[str], List[list], Optional[DistributorComputeBudgetExhausted]
]:
    """Runs a batch of models with random subsets of features.

    Args:
        distributor: Object of class Distributor passed to the main function.
        configs: list of configs to be submitted.

    Returns:

    collected: output of the distribute collector
    runids: list of runids from the distributor
    experiments: list of experiments
    compute_budget_exc: A DistributorComputeBudgetExhausted if one was raised by the distributor
    """
    experiments = []
    runids = []
    compute_budget_exc = None
    try:
        i = 0
        for config in configs:
            i += 1
            exception = None
            for attempt in range(1, NUM_SUBMISSION_ATTEMPTS + 1):
                try:
                    runid = distributor.distribute(config)
                except DistributorComputeBudgetExhausted:
                    # If the distributor runs out of compute budget, raise the exception and
                    # it will be caught outside the outermost loop
                    LOGGER.warning(
                        "Greedy Subset Scorer ran out of compute budget before submitting model %s/%s",
                        i + 1,
                        len(configs),
                    )
                    raise
                except Exception as exc:
                    # All other exceptions should be logged, and the job retried
                    LOGGER.warning(
                        "Error whilst submitting a model! (attempt %s of %s)",
                        attempt,
                        NUM_SUBMISSION_ATTEMPTS,
                        exc_info=exc,
                    )
                    exception = exc
                    # Wait 3 seconds before trying again
                    time.sleep(3)
                else:
                    runids.append(runid)

                    experiments.append(
                        [
                            config["model"]["features"],
                            None,
                            {},
                            config["train"].replace("train_", ""),
                            config["feature_set_id"],
                        ]
                    )
                    break
            else:
                # Max attempts reached to submit model - raise the exception
                raise exception
    except DistributorComputeBudgetExhausted as exc:
        compute_budget_exc = exc

    # Collected is a dict of results:
    # {run=abc: {accuracy: 0, precision: 0},
    # {run=def: {accuracy: 1, precision: 1}}
    try:
        collected = distributor.collect_scores(runids)
    except DistributorException as exc:
        if not exc.results:
            LOGGER.exception(
                "Not a single experiment was successful! Failing...", exc_info=exc
            )
            raise exc
        num_incomplete = len(exc.incomplete_runids)
        LOGGER.warning(
            "Finished collecting, %s models are incomplete or failed!",
            num_incomplete,
            exc_info=exc,
        )
        collected = exc.results

    return collected, runids, experiments, compute_budget_exc


def _collect_batch(
    features: List[str],
    collected: Dict,
    runids: List[str],
    experiments: List,
    metric: str,
    batch_number: int,
    executor_path: URI,
    env: AbstractEnv = compat.env,
):
    """Collects the feature_importances from each model of a batch.

    Args:
        features: list of original feature names
        collected: list of collected distribute job outputs returned by the distribute collector
        runids: list of job runids returned by the distributor
        experiments: list of experiments before collecting the batch results
        metric: chosen metric specified in the config file
        batch_number: current batch run counter value
        executor_path: Directory for the executorrun.
        env: Environment to use.

    Returns:
        batch_output: a pandas dataframe containing feature importances and model performances
        experiments: list of experiments including new experiments resulted from running the batch
    """

    batch_output = None
    for i, runid in enumerate(runids):
        if collected.get(runid) is not None:
            feature_importance_uri = executor_path.model(runid).file(
                "feature_importance.json"
            )
            feature_importances = env.read_jsonish(feature_importance_uri)

            LOGGER.debug(
                "Got feature importances from model %r",
                runid,
                extra={"data": feature_importances},
            )
            for key in feature_importances:
                feature_importances[key] = float(feature_importances[key])

            maximum = feature_importances[
                max(feature_importances, key=feature_importances.get)
            ]
            for key in feature_importances.keys():
                feature_importances[key] = feature_importances[key] / maximum

            if metric in collected[runid].keys():
                experiments[i][1] = collected[runid][metric]
            if experiments[i][1] is None:
                experiments[i][1] = -math.inf

            experiments[i][2] = feature_importances

            # Build a pandas dataframe containing results of all batch experiments:
            exp_output = pd.DataFrame.from_dict(experiments[i][2], orient="index")
            exp_output.columns = ["importance"]
            exp_output.index.name = "feature_name"
            exp_output.reset_index(inplace=True)

            exp_output["module_id"] = runid
            exp_output["batch_number"] = batch_number
            exp_output["test_date"] = experiments[i][3]
            exp_output["feature_set_id"] = str(experiments[i][4])
            # exp_output["feature_set_id"] = str(uuid.uuid4())[0:8]

            for metric_name, metric_value in collected[runid].items():
                # Make sure dictionary metrics like confusion matrix do not come through:
                if isinstance(metric_value, (int, float)):
                    exp_output[metric_name] = metric_value

            # Change dummified feature names:
            dummified_features = _get_dummified_features(
                features, list(set(exp_output["feature_name"]))
            )

            for fn in dummified_features.keys():
                ind = [
                    i
                    for i, v in enumerate(exp_output["feature_name"])
                    if v in dummified_features[fn]
                ]
                exp_output.loc[ind, "feature_name"] = fn

            if batch_output is None:
                batch_output = exp_output
            else:
                batch_output = batch_output.append(exp_output)

        else:
            LOGGER.warning("Runid {} from batch {} failed!".format(runid, batch_number))

    return batch_output, experiments

def _aggregation(raw_scores, settings):
    """Perform aggregation.

    Args:
        raw_scores: Pandas DataFrame of raw scores containing the feature importances
        and model performances of all child models in a melted format

        settings: Dictionary containing feature selection settings. The following keys will be used:
            metric: Chosen metric specified in the config file
            maximise: Whether to maximise or not
            score_aggregator: Which aggregator function should be used
                to compute feature scores among multiple experiments?

    Returns:
        Feature scores after aggregation.
    """
    if settings["maximise"]:
        raw_scores = raw_scores.assign(
            score=raw_scores["importance"] * raw_scores[settings["metric"]]
        )
    else:
        raw_scores = raw_scores.assign(
            score=raw_scores["importance"] * (1.0 - raw_scores[settings["metric"]])
        )

    feature_scores = (
        raw_scores.groupby("feature_name")["score"]
        .agg(settings["score_aggregator"])
        .to_dict()
    )

    return feature_scores


def _save(
    feature_scores: Dict, output: DataFrame, module_path: URI, env: AbstractEnv = compat.env
):
    """Save the final feature importance output.

    Args:
        feature_scores: Dictionary to be saved containing final aggregated scores of
            original features
        output: Pandas data frame to be saved containing results of all experiments
            including feature importances and model performances
        module_path: Folder in which to save output.

    """
    feature_importance_uri = module_path.file("feature_importance.json")
    env.write_jsonish(feature_importance_uri, feature_scores)

    filesystem = env.get_fs_for_uri(module_path)

    raw_scores_uri = module_path.file("raw_scores.csv")
    try:
        with filesystem.open(raw_scores_uri, "w", newline="") as f:
            output.to_csv(f)
    except Exception as exc:
        LOGGER.warning("Failed to write raw scores!", exc_info=exc)


def _set_diff(first, second):
    second = set(second)
    return [item for item in first if item not in second]


def _get_dummified_features(
    original_features: List[str], transformed_features: List[str]
):
    """Finds dummified features among a given list of features.

    Args:
        original_features: Original feature names which do not have any dummified features
        transformed_features: Transformed feature names in which dummified features may exist
    Returns:
        dummified_dict: a dictionary containing original feature names as keys and
            associated dummified feature names as values
    """

    matching = [x for x in original_features if x in str(transformed_features)]

    dummified_dict = {}
    for feature in matching:
        matched_trandformed = [x for x in transformed_features if feature in x]
        dummified_features = [x for x in matched_trandformed if ("_" + feature) in x]
        if len(dummified_features) > 0:
            dummified_dict[feature] = dummified_features
    return dummified_dict
