import copy
import logging
import os

from ell.env.env_abc import AbstractEnv
from ell.env.uri import URI

from ell.predictions import compat, utils
from ell.predictions.errors import DistributorComputeBudgetExhausted, DistributorException
from ell.predictions.distributing import AbstractDistributor

LOGGER = logging.getLogger(__name__)


def walk_backwards_feature_importance(
    config: dict, distributor: AbstractDistributor, module_path: URI, env: AbstractEnv = compat.env
):
    """
    Fit a full model with all features, and get the feature_importance.json. Then find the feature with the worst
    importance, remove it, and train again. If there is a tie for worst, remove them all.

    Continue until we hit our max_features, and then continue while the metric continues improving. If it ever fails
    to improve, we stop at the previous model.

    The following parameters should exist in cfg['feature_selection']

    metric: Name of the metric to optimise, defaults to "f_1"
    maximise: Whether we want to maximise or minimise the metric. Defaults to True
    max_features: The max number of features allowed in the final model, however we keep removing after this
    if it improve the metric

    Args:
        distributor: Distributor instance
        config: Config of the model to fit
        module_path: Directory for this run
        env: Environment to use.

    """
    executor_path = utils.ensure_uri(
        os.path.dirname(module_path.rstrip(r"\/")), is_folder=True
    )

    config = config.pop("feature_selection")
    metric = config.get("metric", "f_1")
    maximise = config.get("maximise", True)
    max_features = config.get("max_features", 50)

    features = config["model"]["features"]

    new_model = copy.deepcopy(config)
    new_model["model"]["features"] = features
    runid = distributor.distribute(new_model)
    results = distributor.collect_scores([runid])
    current_score = results[runid][metric]
    removed = []
    compute_budget_exc = None
    stop = False

    while len(features) > max_features and not stop:
        LOGGER.debug("Getting feature importance")
        feature_importance_uri = executor_path.model(runid).file(
            "feature_importance.json"
        )
        feature_importance = env.read_jsonish(feature_importance_uri)

        LOGGER.debug("Finding least important feature and removing it")

        # Need to recompose feature importances. We don't want to remove a decomposed feature if one of the decomposed
        # features has low importance and one has high importance

        recomposed_feature_importance = {}

        for feature in features:
            for key, value in feature_importance.items():
                if key == feature or key.startswith(feature + "_"):
                    recomposed_feature_importance[feature] = max(
                        float(value), float(recomposed_feature_importance.get(key, 0))
                    )

        if len(recomposed_feature_importance.values()) == 0:
            break

        lowest_score = min(recomposed_feature_importance.values())

        for feature, value in recomposed_feature_importance.items():
            if value == lowest_score:
                LOGGER.debug("Removing feature {} with value {}".format(feature, value))
                removed.append(feature)
                features.remove(feature)

        LOGGER.debug("Setting new feature set to be {}".format(features))

        new_model = copy.deepcopy(config)
        new_model["model"]["features"] = features
        LOGGER.debug("Farming new model with cfg {}".format(config))
        try:
            runid = distributor.distribute(new_model)
        except DistributorComputeBudgetExhausted as exc:
            compute_budget_exc = exc
            LOGGER.warning(
                "Walk Backwards ran out of compute budget when trying to submit the %s model",
                len(removed),
            )
            break

        try:
            results = distributor.collect_scores([runid])
        except DistributorException as exc:
            LOGGER.warning("The %s model failed, continuing", exc_info=exc)
        else:
            score = results[runid][metric]
            if (maximise and score > current_score) or (
                not maximise and score < current_score
            ):
                stop = False
                LOGGER.debug("New score beat old score of {}".format(current_score))
            else:
                LOGGER.debug(
                    "New score did not beat old score of {}".format(current_score)
                )
                stop = True

            current_score = score

    removed.extend(features)

    feature_importance = {}
    for i, feature in enumerate(removed):
        feature_importance[feature] = i

    feature_importance_uri = module_path.file("feature_importance.json")
    env.write_jsonish(feature_importance_uri, feature_importance)

    if compute_budget_exc:
        raise DistributorComputeBudgetExhausted(
            "Walk Backwards could not distribute all jobs"
        ) from compute_budget_exc
