import abc

import inspect
from typing import Any, ClassVar, Dict, Optional, Type

_TRANSFORMER_REGISTRY: Dict[str, Type["AbstractTransformer"]] = {}


class AbstractTransformer(abc.ABC):
    """Abstract base class for transformers.

    Generally, a transformer can be used to:

    #. Fit to a dataset and be used to transform later, i.e. with the
       :meth:`~AbstractTransformer.fit` method,
    #. Fit and transform a dataset at the same time, i.e. with the
       :meth:`~AbstractTransformer.fit_transform` method. This method *may*
       be more efficient, depending on the implementation of the
       specific transformer being used.

    Once you have a transformer which has been fit, you can transform it
    with the :meth:`~AbstractTransformer.transform` method (though some
    transformers don't actually require fitting at all).

    This class defines the basic interface of a transformer, without
    being specific to any data-frame, data analysis, or big data
    library.

    A transformer is generally created from the
    :meth:`AbstractTransformer.from_config` method. The ``type`` field in the
    config determines which transformer is being created.

    Attributes:
        parameters (Dict[str, Any]): A dictionary of parameters as
             specified in the config, with defaults filled out. The
             defaults come from the
             :attr:`~AbstractTransformer.DEFAULT_PARAMETERS` class attribute.
        input_spec (Dict[str, Any]): The "normalised" version of the
            ``input`` field in the config. Because there are some
            short-hand ways of specifying things in the ``input`` field
            (e.g. ``{'include': ['a', 'b']}`` instead of ``{'include':
            {'columns': ['a', 'b']}}``), this attribute has been
            normalised to be consistent (i.e. it will take the more
            verbose form if a short-hand method was specified).
        output_spec (Dict[str, Any]): The "normalised" version of the
            ``output`` field in the config. See
            :attr:`~AbstractTransformer.input_spec` for what "normalised"
            means.
        affects_row_count (bool): If this transformer intends to add or
            remove rows from the dataset, this attribute should be set
            to `True`. For most cases, this is `False`. Some examples
            which could have it set to `True` are Upsamplers, Filters,
            or :class:`Series` transformers which include steps which
            could  affect the row count. A transformer with this
            attribute set to `True` cannot be specified as a step in a
            :class:`Parallel` transformer.
        _target (str): The name of the target column, if any. Defaults
            to 'label'. This can be used by subclasses which need to
            know which column is the target, e.g. the
            :class:`TargetEncoder`.

    """

    DEFAULT_PARAMETERS: ClassVar[Dict[str, Any]] = {}
    """Default parameters for this transformer."""

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        if not inspect.isabstract(cls):
            _TRANSFORMER_REGISTRY[cls.__name__] = cls

    def __init__(self, config: Optional[dict] = None, *, target: str = "label") -> None:
        if config is None:
            config = {}

        # Set default parameters, then override with parameters in
        # config. The default parameters originate from this class, then
        # we move down Python's method resolution order, overwriting
        # default parameters as we go.
        self.parameters = {}
        for cls in reversed(inspect.getmro(type(self))):
            if issubclass(cls, AbstractTransformer):
                self.parameters.update(cls.DEFAULT_PARAMETERS)
        if "parameters" in config:
            self.parameters.update(config["parameters"])

        self.affects_row_count = False
        input_spec = config.get("input")
        if input_spec is None:
            self.input_spec = {}
        elif isinstance(input_spec, list):
            self.input_spec = {"include": {"columns": input_spec}}
        else:
            self.input_spec = input_spec
            if isinstance(self.input_spec.get("include"), list):
                self.input_spec["include"] = {"columns": self.input_spec["include"]}
            if isinstance(self.input_spec.get("exclude"), list):
                self.input_spec["exclude"] = {"columns": self.input_spec["exclude"]}

        output_spec = config.get("output")
        if output_spec is None:
            self.output_spec = {}
        elif isinstance(output_spec, str):
            self.output_spec = {"column_names": [output_spec]}
        elif isinstance(output_spec, list):
            self.output_spec = {"column_names": output_spec}
        else:
            self.output_spec = output_spec

        self._target = target

    @classmethod
    def from_config(cls, config: dict, *, target: str = "label") -> "AbstractTransformer":
        """Create a transformer instance from a config."""
        transformer_type = config["type"]
        if transformer_type not in _TRANSFORMER_REGISTRY:
            raise ValueError(f"Unknown transformer type {transformer_type!r}")
        transformer_cls = _TRANSFORMER_REGISTRY[transformer_type]
        # noinspection PyArgumentList
        return transformer_cls(config, target=target)

    @abc.abstractmethod
    def fit(self, dataset):
        """Fit the transformer to the given input samples."""
        raise NotImplementedError

    @abc.abstractmethod
    def transform(self, dataset, *, is_fit: bool = False):
        """Transform the input samples."""
        raise NotImplementedError

    def fit_transform(self, dataset):
        """Fit and transform the input samples in one operation.

        For some transformers, this method may be more efficient than
        separate :meth:`~AbstractTransformer.fit` and
        :meth:`~AbstractTransformer.transform` calls.
        """
        self.fit(dataset)
        return self.transform(dataset, is_fit=True)

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(parameters={self.parameters!r})"
