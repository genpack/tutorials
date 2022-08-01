import logging
import os
import random
from copy import deepcopy
from dataclasses import dataclass, field, asdict
from functools import reduce
from typing import Any, Dict, Optional, List

import jsonpath_ng as jsonpath
import numpy as np

LOGGER = logging.getLogger(__name__)

MODEL_PARAMETERS_PATH = "$.model.classifier.parameters"

TRIAL_AGGREGATOR_MAP = {
    "mean": np.mean,
    "median": np.median,
    "max": max,
    "min": min,
}


@dataclass
class Trial:
    """Represents the information associated with an HPO trial"""

    trial_id: int
    parameters: Dict[str, Any]
    results: Dict[str, Any] = field(default_factory=dict)
    moduleruns: List[str] = field(default_factory=list)
    exception: Optional[Exception] = None
    failed: bool = False

    def to_dict(self) -> Dict[str, Any]:
        """Convert this Trial object to a dictionary."""

        return asdict(self)

    def to_json(self) -> Dict[str, Any]:
        """Convert this Trial object to a JSON serialisable object."""

        return dict(
            trial_id=self.trial_id,
            failed=self.failed,
            moduleruns=self.moduleruns,
            exception=repr(self.exception),
            results=self.results,
            parameters=self.parameters,
        )

    def to_record(self) -> Dict[str, Any]:
        """Convert this Trial object to a record to be consumed by Pandas"""
        return dict(
            trial_id=self.trial_id,
            failed=self.failed,
            moduleruns=self.moduleruns,
            exception=repr(self.exception),
            **self.results,
            **{f"parameters/{k}": v for k, v in self.parameters.items()},
        )


def configure_model_config(
    config: Dict[str, Any], parameters: Dict[str, Any]
) -> Dict[str, Any]:
    """Updates a model config based on a set of parameters

    By default, all parameters are used to update the values at path
    ``model.classifier.parameters``, except for ``num_features`` which
    (if present) is used to truncate the feature list in the config. Additionally,
    a key in the parameter dict can begin with ``$.`` to reference any point in the
    config via a JSONPath.

    Args:
        config: The model config to update
        parameters: The dictionary of parameters to insert into the config.

    Returns:
        The updated model config
    """
    config = deepcopy(config)
    parameters = deepcopy(parameters)
    num_features = parameters.pop("num_features", None)
    if num_features:
        limited_features = config["model"]["features"][:num_features]
        config["model"]["features"] = limited_features

    for name, value in parameters.items():
        config = set_config_value(config, name, value)

    return config


def set_config_value(dict_: Dict[str, Any], path: str, value: Any) -> Dict[str, Any]:
    """Sets a value defined by a JSONPath in a dictionary

    By default, the path will be appended to ``$.model.classifier.parameters``, unless
    the path starts with ``$.``.

    Args:
        dict_: The dictionary to insert the value into
        path: A string containing a JSONPath specification
        value: The value to set at the path

    Returns:
        A dictionary with the correctly set value
    """
    dict_ = deepcopy(dict_)
    if not path.startswith("$."):
        path = f"{MODEL_PARAMETERS_PATH}.{path}"

    parsed_path = jsonpath.parse(path)

    return parsed_path.update_or_create(dict_, value)


def aggregate_trial_scores(
    scores: Dict[str, Dict[str, Any]], aggregator_name: str
) -> Dict[str, Any]:
    """Aggregate a number of scores dictionaries into a single dictionary

    Args:
        scores: A mapping of runids to scores dictionaries
        aggregator_name: The aggregator to use to combine scores. Must be one of
        ``min``, ``median``, ``mean``, ``max``

    Returns:
        A single scores dictionary with the aggregated value for each metric.
    """
    if aggregator_name not in TRIAL_AGGREGATOR_MAP:
        raise ValueError(
            f"{aggregator_name} is not a supported trial aggregator. "
            f"Expected one of {TRIAL_AGGREGATOR_MAP.keys()}"
        )
    aggregator = TRIAL_AGGREGATOR_MAP[aggregator_name]

    scores = scores.values()
    common_keys = reduce(
        lambda d1, d2: d1 & d2, (set(score.keys()) for score in scores)
    )
    common_keys.discard("confusion_matrix")

    return {key: aggregator([score[key] for score in scores]) for key in common_keys}


def set_random_seed(seed: int):
    os.environ["PYTHONHASHSEED"] = str(seed)
    random.seed(seed)
    np.random.seed(seed)
