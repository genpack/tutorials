import copy
import logging

import numpy as np
from ell.env.env_abc import AbstractEnv
from ell.env.uri import URI

from ell.predictions import compat
from ell.predictions.errors import DistributorComputeBudgetExhausted, DistributorException
from ell.predictions.distributing import AbstractDistributor

LOGGER = logging.getLogger(__name__)


def walk_backwards(
    config: dict, distributor: AbstractDistributor, module_path: URI, env: AbstractEnv = compat.env
):
    """
    Fit a full model with all features, then fit one with each feature missing, evaluate and decide based on metric.
    We continue removing features until we reach the max_features value, at which point we keep removing features
    Until the metric stops improving.

    The following parameters should exist in cfg['feature_selection']

    metric: Name of the metric to optimise, defaults to "f_1"
    maximise: Whether we want to maximise or minimise the metric. Defaults to True
    max_features: The max number of features allowed in the final model, however we keep removing after this
    if it improve the metric

    Args:
        config: Config of the model to fit
        distributor: Distributor instance
        module_path: Directory for this run
        env: Environment to use.

    """
    config = config.pop("feature_selection")
    metric = config.get("metric", "f_1")
    maximise = config.get("maximise", True)
    max_features = config.get("max_features", 50)

    features = config["model"]["features"]

    feature_importance = {}
    removed = []

    stop = False
    if maximise:
        current_score = 0
    else:
        current_score = np.inf

    compute_budget_exc = None
    while len(features) > max_features or stop is False:

        runids = []
        subsets = []
        configs = []
        LOGGER.info("Testing subsets")

        for feature in features:
            LOGGER.debug("Farming subset without feature {}".format(feature))
            new_model = copy.deepcopy(config)
            new_features = [x for x in features if x != feature]
            new_model["model"]["features"] = new_features
            LOGGER.debug("Farming config {}".format(new_model))

            try:
                runid = distributor.distribute(new_model)
            except DistributorComputeBudgetExhausted as exc:
                compute_budget_exc = exc
                LOGGER.warning(
                    "Walk Backwards ran out of compute budget when trying to distribute model without %s",
                    feature,
                )
                break
            else:
                configs.append(new_model)
                runids.append(runid)
                subsets.append([new_features, runid, feature])

        try:
            results = distributor.collect_scores(runids)
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
            results = exc.results
        LOGGER.debug("Collected results {}".format(results))

        for subset in subsets:
            score = results[subset[1]][metric]
            subset[1] = score

        LOGGER.debug("Subsets and scores {}".format(subsets))

        if maximise:
            best_subset = max(subsets, key=lambda x: x[1])
        else:
            best_subset = min(subsets, key=lambda x: x[1])

        best_score = best_subset[1]
        LOGGER.debug("Best subset: {}".format(best_subset))
        LOGGER.debug("Best score: {}".format(best_score))
        LOGGER.debug("Removed feature {}".format(best_subset[2]))

        removed.append(best_subset[2])

        if best_score > current_score:
            stop = False
            LOGGER.debug(
                "New best score beat old best score of {}".format(current_score)
            )
        else:
            LOGGER.debug(
                "New best score did not beat old best score of {}".format(current_score)
            )
            stop = True

        current_score = best_score
        LOGGER.debug("Setting new feature set to be {}".format(features))
        features = best_subset[0]

        if compute_budget_exc:
            break

    removed.extend(features)

    for i, feature in enumerate(removed):
        feature_importance[feature] = i

    feature_importance_uri = module_path.file("feature_importance.json")
    env.write_jsonish(feature_importance_uri, feature_importance)

    if compute_budget_exc:
        raise DistributorComputeBudgetExhausted(
            "Walk Backwards could not distribute all jobs"
        ) from compute_budget_exc
