import abc
import inspect
from typing import Any, ClassVar, Dict, Optional

_CALIBRATOR_REGISTRY = {}


class AbstractCalibrator(abc.ABC):
    """Abstract base class for calibrators."""

    DEFAULT_PARAMETERS: ClassVar[Dict[str, Any]] = {}

    # This method is called every time this class is *subclassed* (note:
    # not when each subclass is *instantiated*, but actually when the
    # "class" statement is executed). Its point is to fill the
    # _CALIBRATOR_REGISTRY with implementations of this class, so that the
    # AbstractCalibrator.from_config() method can find the right class for
    # a given model name.
    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        if not inspect.isabstract(cls):
            _CALIBRATOR_REGISTRY[cls.__name__] = cls

    def __init__(self, config: Optional[dict] = None) -> None:
        """Initialise calibrator.

        Args:
            config (Optional[dict]): Configuration for this calibrator.

        """
        if config is None:
            config = {}

        # Set default parameters, then override with parameters in
        # config. The default parameters originate from this class, then
        # we move down Python's method resolution order, overwriting
        # default parameters as we go.
        self.parameters = {}
        for cls in reversed(inspect.getmro(type(self))):
            if issubclass(cls, AbstractCalibrator):
                self.parameters.update(cls.DEFAULT_PARAMETERS)
        if "parameters" in config:
            self.parameters.update(config["parameters"])

    @classmethod
    def from_config(cls, config: dict) -> "AbstractCalibrator":
        """Create a calibrator instance from a config."""
        calibrator_name = config["type"]
        if calibrator_name not in _CALIBRATOR_REGISTRY:
            raise ValueError(f"Unknown calibrator type {calibrator_name!r}")
        calibrator_cls = _CALIBRATOR_REGISTRY[calibrator_name]
        return calibrator_cls(config)

    @abc.abstractmethod
    def fit(self, probas) -> None:
        raise NotImplementedError

    @abc.abstractmethod
    def transform(self, probas):
        raise NotImplementedError
