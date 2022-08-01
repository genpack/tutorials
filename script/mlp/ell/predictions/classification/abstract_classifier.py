"""Contains an abstract base class for classification models so we can standardize
our interfaces with them.
"""
import abc
import inspect
import logging
from abc import ABC
from typing import Any, ClassVar, Dict, Optional, Type

from ell.env.env_abc import AbstractEnv

from ell.predictions import compat
from ell.predictions.calibration import AbstractCalibrator

LOGGER = logging.getLogger(__name__)

_MODEL_REGISTRY: Dict[str, Type["AbstractClassifier"]] = {}


class AbstractClassifier(ABC):
    """Abstract base class for classification models."""

    DEFAULT_PARAMETERS: ClassVar[Dict[str, Any]] = dict(
        verbose=True,
    )

    # This method is called every time this class is *subclassed* (note:
    # not when each subclass is *instantiated*, but actually when the
    # "class" statement is executed). Its point is to fill the
    # _MODEL_REGISTRY with implementations of this class, so that the
    # AbstractClassifier.from_config() method can find the right class for
    # a given model name.
    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        if not inspect.isabstract(cls):
            _MODEL_REGISTRY[cls.__name__] = cls

    def __init__(self, config: Optional[dict] = None) -> None:
        """Initialize abstract classification super class.

        Args:
            config (dict): Configuration for this model.

        """
        if config is None:
            config = {}

        # Set default parameters, then override with parameters in
        # config. The default parameters originate from this class, then
        # we move down Python's method resolution order, overwriting
        # default parameters as we go.
        self.parameters = {}
        for cls in reversed(inspect.getmro(type(self))):
            if issubclass(cls, AbstractClassifier):
                self.parameters.update(cls.DEFAULT_PARAMETERS)
        if "parameters" in config:
            self.parameters.update(config["parameters"])
        self.cutpoint = self.parameters.get("cutpoint", 0.5)
        self.target = config.get("target", "label")

        if config.get("calibrator"):
            self.calibrator = AbstractCalibrator.from_config(config=config["calibrator"])
        else:
            self.calibrator = None

    @classmethod
    def from_config(cls, config: dict) -> "AbstractClassifier":
        """Create a model instance from a config."""
        classifier_type = config["type"]
        if classifier_type not in _MODEL_REGISTRY:
            raise ValueError(f"Unknown classifier type {classifier_type!r}")
        model_cls = _MODEL_REGISTRY[classifier_type]
        return model_cls(config)

    @abc.abstractmethod
    def fit(self, dataset):
        """Fit the model to a training dataset."""
        raise NotImplementedError

    @abc.abstractmethod
    def optimise_threshold(self, dataset, **kwargs):
        """Optimise the decision boundary with an optimising dataset."""
        raise NotImplementedError

    @abc.abstractmethod
    def score(self, dataset):
        """Evaluate the model with a testing dataset."""
        raise NotImplementedError

    @abc.abstractmethod
    def predict(self, dataset, *, return_labels=False):
        """Transform the input samples and predict.

        Args:
            dataset: The input samples to predict.
            return_labels (bool): When True, the returned data structure
                containing categories will also contain the classes for
                the input samples (if the input samples are indeed
                labelled).

        Returns:
            A table containing the raw predictions for each class
            (a.k.a. probabilities), and a table containing the predicted
            class for each sample (a.k.a. categories) under column
            "category", and optionally the classes for each input sample
            (if ``return_labels`` is True and the input data contains
            classes) under the column "label".

        """
        raise NotImplementedError

    def save_diagnostics(self, folder_uri: str, env: AbstractEnv = compat.env) -> None:
        """Saves any additional information specific to a model."""
        pass

    def __repr__(self) -> str:
        return (
            f"{self.__class__.__name__}(target={self.target!r}, "
            f"cutpoint={self.cutpoint!r}, "
            f"parameters={self.parameters!r}, "
            f"calibrator={self.calibrator!r})"
        )
