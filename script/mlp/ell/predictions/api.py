__all__ = ["train", "infer", "optimise_hyper_parameters", "select_features"]

import logging
import os
import sys
from typing import Tuple

import pandas as pd
from ell.env.env_abc import AbstractEnv

from . import compat, feature_selection, utils, classification
from .classification import Scores, plots
from .ensembling import AbstractAverager
from .distributing import AbstractDistributor
from .hpo import AbstractTuner
from .model import Model

LOGGER = logging.getLogger(__name__)

GB = 1 << 30


def train(
    config: dict, module_path: str, data_path: str, env: AbstractEnv = compat.env
) -> Model:
    """Create a model, fit it, evaluate it, then persist it.

    Args:
        config: Full prediction train config.
        module_path: Directory where the run's output files should be
            written to.
        data_path: Directory where input datasets are located.
        env: Environment to use.

    Returns:
        Model: The trained model.

    """
    LOGGER.info("Starting model training...")

    module_path = utils.ensure_uri(module_path, is_folder=True)
    data_path = utils.ensure_uri(data_path, is_folder=True)

    LOGGER.debug("Training config", extra={"data": config})
    model = Model.from_config(config["model"])

    max_memory_gb = config.get("max_memory_GB")
    batch_size = max_memory_gb * GB if max_memory_gb else None

    LOGGER.info("Retrieving encodings")
    encodings_uri = data_path.file("categorical_encodings.json")
    encodings = env.read_jsonish(encodings_uri)

    loader_kwargs = dict(
        columns=model.features + model.labels if model.features else None,
        index_columns=["caseID", "eventTime"],
        encodings=encodings,
        batch_size=batch_size,
        env=env,
    )
    predictions_path = module_path.folder("predictions")
    etc_path = module_path.folder("etc")

    scores_df = None

    if isinstance(model.estimator, AbstractAverager) and config.get("enable_distributor", True):
        # If it's an ensembler, we don't download the train dataset to
        # the main modulerun container.
        executor_path = utils.ensure_uri(
            os.path.dirname(module_path.rstrip(r"\/")), is_folder=True
        )

        # Extracting distributor options
        distributor_options = config.get("distributor", {})
        compute_budget_spec = distributor_options.get("total_compute_budget")
        model_timeout_spec = distributor_options.get("model_timeout")

        distributor = AbstractDistributor.create(
            executor_path,
            data_path,
            config_filler=utils.create_config_filler(config),
            env=env,
            model_timeout=model_timeout_spec,
            compute_budget=compute_budget_spec,
        )
        model.fit(dataset=None, distributor=distributor)

        if config.get("evaluate_train"):
            LOGGER.warning(
                "Evaluating the train dataset is not currently supported by ensemblers"
            )
    else:
        train_path = data_path.folder(config.get("train", "train"))
        with utils.ParquetDatasetLoader(train_path, **loader_kwargs) as loader:
            dataset = loader.maybe_get_batches()
            model.fit(dataset)

            if config.get("evaluate_train"):
                LOGGER.info("Evaluating the train dataset")
                proba_df, cats_df = model.predict(dataset, return_labels=True)
                preds_uri = predictions_path.file("predictions_train.parquet")
                scores_uri = module_path.file("scores_train.json")
                utils.persist_predictions(preds_uri, proba_df, cats_df, env=env)
                scores = Scores.calculate(
                    y_true=cats_df["label"],
                    y_pred=cats_df["category"],
                    probas=proba_df,
                )
                env.write_jsonish(uri=scores_uri, data=scores.to_dict())
                scores_df = scores.to_df(dataset_name="train")
                cumgain_fig, lift_fig, dist_fig = plots.get_standard_plots(
                    y_true=cats_df["label"], proba_df=proba_df
                )
                utils.persist_plots(
                    figures=dict(
                        train_cum_gain=cumgain_fig,
                        train_lift=lift_fig,
                        train_dist=dist_fig,
                    ),
                    output_path=etc_path,
                    env=env,
                )

    if config.get("optimise"):
        optimise_path = data_path.folder("optimise")
        with utils.ParquetDatasetLoader(optimise_path, **loader_kwargs) as loader:
            dataset = loader.maybe_get_batches()
            model.optimise_threshold(dataset, cutoff=config["optimise"])

    test_path = data_path.folder(config.get("test", "test"))
    preds_uri = predictions_path.file("predictions.parquet")
    scores_uri = module_path.file("scores.json")
    with utils.ParquetDatasetLoader(test_path, **loader_kwargs) as loader:
        dataset = loader.maybe_get_batches()
        proba_df, cats_df = model.predict(dataset, return_labels=True)

    utils.persist_predictions(preds_uri, proba_df, cats_df, env=env)
    if compat.ON_ECS:
        # This first table is deprecated, as it has no suffix. It is to
        # be removed after the April 2021 Event Prediction Platform Refresh.
        utils.create_glue_table(
            executorrun=compat.EXECUTORRUN,
            modulerun=compat.MODULERUN,
            s3_path=module_path.folder("predictions"),
            schema=utils.get_predictions_glue_schema(cats_df),
        )
        utils.create_glue_table(
            executorrun=compat.EXECUTORRUN,
            modulerun=compat.MODULERUN,
            s3_path=module_path.folder("predictions"),
            schema=utils.get_predictions_glue_schema(cats_df),
            table_name_suffix="predictions",
        )

    scores = Scores.calculate(
        y_true=cats_df["label"],
        y_pred=cats_df["category"],
        probas=proba_df,
    )
    env.write_jsonish(uri=scores_uri, data=scores.to_dict())

    test_scores_df = scores.to_df(dataset_name="test")
    scores_df = (
        test_scores_df if scores_df is None else pd.concat([scores_df, test_scores_df])
    )
    scores_df_uri = module_path.folder("scores").file("scores.parquet")
    utils.persist_prediction_scores_df(scores_df, scores_df_uri)
    if compat.ON_ECS:
        utils.create_glue_table(
            executorrun=compat.EXECUTORRUN,
            modulerun=compat.MODULERUN,
            s3_path=module_path.folder("scores"),
            schema=classification.Scores.get_glue_schema(),
            table_name_suffix="scores",
        )
    if sys.platform != "darwin":
        # Saving plots on MacOS seems to cause a segfault
        cumgain_fig, lift_fig, dist_fig = plots.get_standard_plots(
            y_true=cats_df["label"], proba_df=proba_df
        )
        utils.persist_plots(
            figures=dict(
                test_cum_gain=cumgain_fig,
                test_lift=lift_fig,
                test_dist=dist_fig,
            ),
            output_path=etc_path,
            env=env,
        )

    model.save(module_path, env=env)
    LOGGER.info("Model training finished")

    return model


def infer(
    config: dict,
    module_path: str,
    model_uri: str,
    data_path: str,
    env: AbstractEnv = compat.env,
) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """Unpickle a model, predict, and persist the predictions.

    Args:
        config: Full prediction infer config.
        module_path: Directory where the run's output files should be
            written to.
        model_uri: URI to where the model to be loaded is located.
        data_path: Directory where input datasets are located.
        env: Environment to use.

    Returns:
        Predicted probabilities in shape (n_samples, n_classes) and
        predicted categories in shape (n_samples, 1).

    """
    LOGGER.info("Starting model inference...")

    module_path = utils.ensure_uri(module_path, is_folder=True)
    model_uri = utils.ensure_uri(model_uri, is_folder=not model_uri.endswith(".pkl"))
    data_path = utils.ensure_uri(data_path, is_folder=True)

    LOGGER.debug("Infer config", extra={"data": config})
    model = utils.load_model(model_uri, env=env)

    dataset_spec = config.get("dataset")
    if isinstance(dataset_spec, dict) and "sampled" in dataset_spec:
        dataset_spec = dataset_spec["sampled"]
    if isinstance(dataset_spec, dict):
        sampled_folder = dataset_spec.get("folder", "infer")
    else:
        sampled_folder = "infer"
    infer_path = data_path.folder(sampled_folder)

    max_memory_gb = config.get("max_memory_GB")
    batch_size = max_memory_gb * GB if max_memory_gb else None

    LOGGER.info("Retrieving encodings")
    encodings_uri = data_path.file("categorical_encodings.json")
    encodings = env.read_jsonish(encodings_uri)

    loader_kwargs = dict(
        columns=model.features if model.features else None,
        index_columns=["caseID", "eventTime"],
        encodings=encodings,
        batch_size=batch_size,
        env=env,
    )

    with utils.ParquetDatasetLoader(infer_path, **loader_kwargs) as loader:
        dataset = loader.maybe_get_batches()
        proba_df, cats_df = model.predict(dataset)

    predictions_uri = module_path.folder("predictions").file("predictions.parquet")
    utils.persist_predictions(predictions_uri, proba_df, cats_df, env=env)
    if compat.ON_ECS:
        # This first table is deprecated, as it has no suffix. It is to
        # be removed after the April 2021 Event Prediction Platform Refresh.
        utils.create_glue_table(
            executorrun=compat.EXECUTORRUN,
            modulerun=compat.MODULERUN,
            s3_path=module_path.folder("predictions"),
            schema=utils.get_predictions_glue_schema(cats_df),
        )
        utils.create_glue_table(
            executorrun=compat.EXECUTORRUN,
            modulerun=compat.MODULERUN,
            s3_path=module_path.folder("predictions"),
            schema=utils.get_predictions_glue_schema(cats_df),
            table_name_suffix="predictions",
        )

    LOGGER.info("Model inference finished")

    return proba_df, cats_df


def optimise_hyper_parameters(
    config: dict, executor_path: str, data_path: str, env: AbstractEnv = compat.env
) -> dict:
    """Run an HPO.

    Args:
        config: Full prediction HPO config.
        executor_path: Directory where the run's output files should be
            written to.
        data_path: Directory where input datasets are located.
        env: Environment to use.

    Returns:
        HPO results in dictionary format.

    """
    LOGGER.info("Starting Hyper-parameter optimisation...")

    executor_path = utils.ensure_uri(executor_path, is_folder=True)
    data_path = utils.ensure_uri(data_path, is_folder=True)

    LOGGER.debug("HPO config", extra={"data": config})
    hpo = AbstractTuner.from_config(config)

    # Extracting distributor options
    distributor_options = config.get("distributor", {})
    compute_budget_spec = distributor_options.get("total_compute_budget")
    model_timeout_spec = distributor_options.get("model_timeout")

    distributor = AbstractDistributor.create(
        executor_path,
        data_path,
        env=env,
        model_timeout=model_timeout_spec,
        compute_budget=compute_budget_spec,
    )

    LOGGER.info("Starting HPO %s", hpo.__class__.__name__)
    hpo_results = hpo.optimise(distributor)
    LOGGER.info("Hyper-parameter optimisation finished")

    hpo_results_uri = executor_path.file("hpo.json")
    env.write_jsonish(hpo_results_uri, hpo_results)

    return hpo_results


def select_features(
    config: dict, module_path: str, data_path: str, env: AbstractEnv = compat.env
) -> dict:
    """Run a feature selector.

    Args:
        config: Full prediction feature-selection config.
        module_path: Directory where the run's output files should be
            written to.
        data_path: Directory where input datasets are located.
        env: Environment to use.

    Returns:
        Feature importances in dictionary format.

    """
    LOGGER.debug("Starting feature selection...")

    module_path = utils.ensure_uri(module_path, is_folder=True)
    data_path = utils.ensure_uri(data_path, is_folder=True)

    executor_path = utils.ensure_uri(
        os.path.dirname(module_path.rstrip(r"\/")), is_folder=True
    )

    # Extracting distributor options
    distributor_options = config.get("distributor", {})
    compute_budget_spec = distributor_options.get("total_compute_budget")
    model_timeout_spec = distributor_options.get("model_timeout")

    distributor = AbstractDistributor.create(
        executor_path,
        data_path,
        env=env,
        model_timeout=model_timeout_spec,
        compute_budget=compute_budget_spec,
    )

    algorithm = config["feature_selection"]["algorithm"]
    try:
        feature_selector = getattr(feature_selection, algorithm)
    except AttributeError:
        raise ValueError(f"Unknown feature-selection algorithm {algorithm!r}")

    LOGGER.info("Running feature-selection algorithm %r", algorithm)
    # For now, the feature selector should write out its own results.
    # In the future, we should update this so it gets written out in
    # this function.
    results = feature_selector(config, distributor, module_path, env)

    LOGGER.debug("Feature-selection results", extra={"data": results})
    return results
