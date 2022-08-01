"""
Contains an abstract base class to standardize the interface between our various describer models
"""
import inspect
import logging
import warnings
from abc import ABC
from typing import Dict, Sequence, Type

import pandas as pd

LOGGER = logging.getLogger(__name__)

_DESCRIBER_REGISTRY: Dict[str, Type["AbstractDescriber"]] = {}


class AbstractDescriber(ABC):
    """
    Abstract base class for el describer models.
    """

    def __init_subclass__(cls, *, aliases: Sequence[str] = (), **kwargs):
        super().__init_subclass__(**kwargs)
        if not inspect.isabstract(cls):
            _DESCRIBER_REGISTRY[cls.__name__] = cls
            for alias in aliases:
                if alias in _DESCRIBER_REGISTRY:
                    # Ensure aliases are unique
                    other_cls = _DESCRIBER_REGISTRY[alias]
                    raise ValueError(
                        f"{alias!r} cannot be used as an alias for {cls.__name__} "
                        f"since it is already an alias for {other_cls.__name__}"
                    )
                _DESCRIBER_REGISTRY[alias] = cls

    def __init__(
        self, X, encodings, predict_or_get_probabilities, predict_or_get_categories
    ):
        """

        :param X: Dataset to fit the describer on
        :param encodings: categorical_encodings dict associated with X
        :param predict_or_get_probabilities: Model probability function
        :param predict_or_get_categories: Model category function
        """
        self.X = X
        self.categoricals = encodings.keys()
        self.encodings = encodings

        self.categoricals = [a for a in self.categoricals if a in X.columns]

        def prob_wrapper(X):
            X = pd.DataFrame(X, columns=self.X.columns)
            return predict_or_get_probabilities(X)

        def cat_wrapper(X):
            X = pd.DataFrame(X, columns=self.X.columns)
            return predict_or_get_categories(X)

        self.predict_probabilities_fn = prob_wrapper
        self.predict_categories_fn = cat_wrapper

    @classmethod
    def create(cls, *, describer_name: str, **kwargs) -> "AbstractDescriber":
        """Create a model instance from a config."""
        if "." in describer_name:
            full_name = describer_name
            _, describer_name = describer_name.rsplit(".", 1)
            warnings.warn(
                f"Providing the fully qualified name of an describer (e.g. "
                f"{full_name!r}) has been deprecated. Instead, simply provide the "
                f"unqualified name (e.g. {describer_name!r})",
                category=DeprecationWarning,
            )
        if describer_name not in _DESCRIBER_REGISTRY:
            raise ValueError(f"Unknown describer name {describer_name!r}")
        describer_cls = _DESCRIBER_REGISTRY[describer_name]
        return describer_cls(**kwargs)

    def describe_raw(self, row, verbose, **params):
        """
        Produces an explanation from the underlying native describer model, without our formatting on top.
        Useful for debugging or situations which require the raw explanation. Also accepts any parameters for the
        specific describer model

        :param row: The row to describe
        :param verbose: Verbosity switch
        :returns: Explanation
        """

    def describe(self, row, verbose, **params):
        """
        Produce an explanation for this row, using whatever kind of explanation this describer natively produces.

        :param row: The row we want to describe
        :param verbose: Verbosity switch
        :returns: A tuple of (prediction, explanations)
        """

    def get_box(self, row, exclude_categoricals=None, features=None, **params):
        """
        Outputs a boxlike explanation so we can compare. Returns a dict
        where each key is a feature and the entry is another dict, with 'upper' and
        'lower' being the boundaries of the box. Sometimes a boundary is None, when
        the box extends to the edge of the universe

        Note that a box in feature A with upper U and lower W is interpreted
        as L < A <= U. The upper bound is inclusive, the lower is not. This
        helps us deal with categorical variables in a simple way.

        :param exclude_categoricals: List of categoricals to not dummify. These might be things like a postcode, where decomposition leads to data which is too high dimensional.
        :param features: List of features that we are to use for getting explanations. Explanations may only involve these features. Defaults to None, where all features will be used
        :param row: The row we want to describe
        :returns: A boxlike explanation. A dict, where the key is a feature and the entry is another dict with an
        upper and lower value.
        """
