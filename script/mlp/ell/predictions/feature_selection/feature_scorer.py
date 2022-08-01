"""
Module to build a feature importance score for each feature by training random subsets of features and determnining
the effect on the accuracy of the model of leaving out a features.
"""
import logging
import os
from copy import deepcopy

import numpy as np
from ell.env.env_abc import AbstractEnv
from ell.env.uri import URI

from ell.predictions import compat, utils
from ell.predictions.errors import DistributorComputeBudgetExhausted, DistributorException
from ell.predictions.distributing import AbstractDistributor

LOGGER = logging.getLogger(__name__)


def feature_scorer(
    config: dict, distributor: AbstractDistributor, module_path: URI, env: AbstractEnv = compat.env
):
    """
    Given a config file which specifies a model, we obtain scores of model importance by fitting random subsets
    of features and measuring the impact that the inclusion/exclusion of a particular feature has
    :returns: 2d list. First list is a list of features in score order, second is a list of scores
    """
    executor_path = utils.ensure_uri(
        os.path.dirname(module_path.rstrip(r"\/")), is_folder=True
    )

    fs_config = config.pop("feature_selection")
    num_subsets = fs_config.get("num_subsets", 20)
    subset_size = fs_config.get("subset_size", 0.8)
    metric = fs_config.get("metric", "f_1")
    features = config["model"]["features"]

    subset_size = int(len(features) * subset_size)
    LOGGER.info("Performing experiments in {} features".format(subset_size))

    experiments = []
    runids = []
    compute_budget_exc = None
    for i in range(0, num_subsets):
        LOGGER.info("Farming experiment {} out of {}".format(i, num_subsets))
        subset = list(np.random.choice(features, subset_size, replace=False))
        new_config = deepcopy(config)
        new_config["model"]["features"] = subset
        try:
            runids.append(distributor.distribute(new_config))
        except DistributorComputeBudgetExhausted as exc:
            compute_budget_exc = exc
            LOGGER.warning(
                "Subset Scorer ran out of compute hours before submitting subset %s/%s",
                i,
                num_subsets,
            )
            break
        experiments.append([subset, None, None])

    LOGGER.debug("Experiments array after distributing: {}".format(experiments))

    # Need to separate distributing and collecting so we can parallelise training models
    LOGGER.debug("Collecting runids {}".format(runids))
    try:
        collected = distributor.collect_scores(runids)
    except DistributorException as exc:
        if not exc.results:
            LOGGER.exception(
                "Not a single experiment was successful! Failing...", exc_info=exc
            )
            raise exc
        LOGGER.warning(
            "Finished collecting, %s models are incomplete or failed!",
            len(exc.incomplete_runids),
            exc_info=exc,
        )
        collected = exc.results

    LOGGER.debug("Collected scores", extra={"data": collected})
    # collected is a dict of results:
    # {run=abc: {accuracy: 0, precision: 0},
    # {run=def: {accuracy: 1, precision: 1}}

    for i in range(0, num_subsets):
        if collected[runids[i]] is not None:
            feature_importance_uri = executor_path.model(runids[i]).file(
                "feature_importance.json"
            )
            feature_importances = env.read_jsonish(feature_importance_uri)

            LOGGER.debug(
                "Got feature importances from model %r",
                runids[i],
                extra={"data": feature_importances},
            )
            for key in feature_importances:
                feature_importances[key] = float(feature_importances[key])

            maximum = feature_importances[
                max(feature_importances, key=feature_importances.get)
            ]
            for key in feature_importances.keys():
                feature_importances[key] = feature_importances[key] / maximum

            experiments[i][1] = collected[runids[i]][metric]
            experiments[i][2] = feature_importances

    LOGGER.debug("Experiments array after collecting", extra={"data": experiments})

    returns = {}
    # Given experiments, we want to find an average score every time a feature is included
    for feature in features:
        LOGGER.debug("Collecting results for feature {}".format(feature))
        max_score = 0
        for experiment in experiments:
            if feature in experiment[0] and experiment[1] is not None:

                # Sometimes a single feature like gender gets dummified into gender_1.0, gender_0.0, etc. So we
                # have to collect them all
                dummified_features = [
                    x
                    for x in experiment[2].keys()
                    if x.startswith("T0_Dummifier_" + feature + "_")
                    or x.startswith("T1_FunctionTransformer_" + feature)
                    or x.startswith("T0_" + feature + "_")
                    or x.startswith("T1_" + feature)
                    or x == feature
                ]

                a = [float(experiment[2][x]) for x in dummified_features]
                if a == []:
                    a = [0]
                max_dummified_score = max(a)

                LOGGER.debug("Dummified features {}".format(dummified_features))
                LOGGER.debug("Max dummified feature {}".format(max_dummified_score))
                LOGGER.debug("Features in this experiment {}".format(experiment[0]))
                LOGGER.debug("Score for this experiment {}".format(experiment[1]))
                score = float(experiment[1]) * max_dummified_score
                max_score = max(score, max_score)

        returns[feature] = max_score

    LOGGER.debug("Writing out feature importances", extra={"data": returns})
    feature_importance_uri = module_path.file("feature_importance.json")
    env.write_jsonish(feature_importance_uri, returns)

    LOGGER.info("Finished subset scorer")

    if compute_budget_exc:
        raise DistributorComputeBudgetExhausted(
            "Subset Scorer could not distribute all jobs"
        ) from compute_budget_exc
