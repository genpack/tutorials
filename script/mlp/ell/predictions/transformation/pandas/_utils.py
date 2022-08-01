import contextlib
import logging
from typing import Any, Callable, Dict, List, Sequence, TYPE_CHECKING, TypeVar, Union

import numpy as np
import pandas as pd

from ... import utils

if TYPE_CHECKING:
    from .pandas_transformer_abc import PandasAbstractTransformer

LOGGER = logging.getLogger(__name__)

_T = TypeVar("_T")


def filter_df(
    df: pd.DataFrame,
    input_spec: Dict[str, Any],
    target: str,
    is_fit: bool,
) -> pd.DataFrame:
    """Filter the data-frame based on the ``input`` spec.

    This function is what actually does the filtering of a data-frame
    based on the ``input`` field of a transformer config. It also does
    its best to validate the ``input``, and will raise an error if any
    options are specified incorrectly.

    The ``input`` field can have these top-level keys:

    - **include** (list or dict) - Specification of columns to include
      as input to the transformer.
    - **exclude** (list or dict) - Specification of columns to exclude
      from the input to the transformer.
    - **include_before_exclude** (bool) - If `True`, this function will
      perform exclusions before inclusions, to change the behaviour if
      the specifications overlap. Defaults to `False`.

    **include** and **exclude** can either be lists of explicit columns,
    or can be a dictionary to specify filtering by feature class, or
    something else. If they're a dictionary, the following keys are
    allowed:

    - **columns** (list) - An explicit list of column names to include
      (or exclude).
    - **categoricals** (bool or dict): If a bool, `True` means include
      (or exclude) all categorical variables. To avoid confusion,
      `False` is considered invalid. If a dict, if must have at least
      one of the keys **min_cardinality** or **max_cardinality**, which
      filter down to categoricals which fit within that range of
      cardinality. The bounds of this range are inclusive.
    - **numericals** (bool): If `True`, all numerical variables will be
      included (or excluded). To avoid confusion, `False` is considered
      invalid.
    - **target** (bool): If `True`, the target column will be included
      (or excluded), so long as ``is_fit`` is True.

    Args:
        df: The data-frame to filter down.
        input_spec: The ``input`` field from the config.
        target: The name of the target column.
        is_fit: If True, this filtering is being done on a transformer
            which is being fit. If ``False``, then the ``target`` column
            will not be passed in (even if ``target: true`` is specified
            in ``input_spec.include``.

    Returns:
        The data-frame filtered down as specified.

    """
    input_spec = input_spec.copy()
    include_spec = input_spec.pop("include", [])
    exclude_spec = input_spec.pop("exclude", [])
    exclude_before_include = input_spec.pop("exclude_before_include", False)
    input_spec.pop("remainder", None)

    if input_spec:
        raise ValueError(
            f"The following invalid keys were provided to the `input` spec: "
            f"{', '.join(map(str, input_spec.keys()))}"
        )

    # Break up include and exclude into 'steps', which follow similar
    # but inverse logic.
    steps = [(include_spec, True), (exclude_spec, False)]
    # `exclude_before_include` just means reversing the steps.
    if exclude_before_include:
        steps.reverse()

    for spec, is_include in steps:
        if not spec:
            continue

        # "key" is just what we're using to pass into error messages
        key = "include" if is_include else "exclude"

        if isinstance(spec, dict):
            filter_list = []

            # Categorical specification. Either True to include all
            # categoricals, or a dict to specify a min/max cardinality,
            # or not specified at all
            if "categoricals" in spec:
                cat_spec = spec["categoricals"]
                # noinspection PyTypeChecker
                cat_columns = utils.get_categorical_cols(df)
                with contextlib.suppress(ValueError):
                    cat_columns.remove(target)
                if cat_spec is True:
                    filter_list.extend(cat_columns)
                elif isinstance(cat_spec, dict):
                    # If a dictionary, it must have at least *one* of
                    # `min_cardinality` or `max_cardinality`.
                    if not cat_spec:
                        raise ValueError(
                            f"Invalid `{key}.categoricals` spec {cat_spec}"
                        )
                    cat_spec = cat_spec.copy()
                    max_cardinality = cat_spec.pop("max_cardinality", np.inf)
                    min_cardinality = cat_spec.pop("min_cardinality", -np.inf)
                    if cat_spec:
                        raise ValueError(
                            f"Invalid `{key}.categoricals` spec {cat_spec}"
                        )

                    # Add columns which have a uniqueness count within
                    # the given range
                    uniq_count = df.dtypes[cat_columns].apply(
                        lambda dtype: len(dtype.categories)
                    )
                    filter_list.extend(
                        uniq_count[
                            (uniq_count >= min_cardinality)
                            & (uniq_count <= max_cardinality)
                        ].index
                    )
                else:
                    raise ValueError(f"Invalid `{key}.categoricals` spec {cat_spec}")

            # Numerical specification. Either True or not specified at
            # all
            if "numericals" in spec:
                num_spec = spec["numericals"]
                if num_spec is True:
                    numerical_columns = utils.get_numerical_cols(df)
                    with contextlib.suppress(ValueError):
                        numerical_columns.remove(target)
                    filter_list.extend(numerical_columns)
                else:
                    raise ValueError(f"Invalid `{key}.numericals` spec {num_spec}")

            # Explicit columns. Must be a list of strings.
            if "columns" in spec:
                col_spec = spec["columns"]
                if isinstance(col_spec, list):
                    filter_list.extend(col_spec)
                else:
                    raise ValueError(f"Invalid `{key}.columns` spec {col_spec}")

            # Target specification. Must be True or not specified at all
            if "target" in spec:
                target_spec = spec["target"]
                if target_spec is True:
                    if is_include and is_fit and target not in df.columns:
                        raise ValueError(
                            f"`{key}.target` is True but target column {target!r} "
                            f"is missing from the DataFrame!"
                        )
                    filter_list.append(target)
                else:
                    raise ValueError(f"Invalid `{key}.target` spec {target_spec}")

        elif isinstance(spec, list):
            # A list is the same as {'columns': ...}
            filter_list = spec
        else:
            raise ValueError(f"Invalid `{key}` spec {spec}")

        # Determine missing columns which were explicitly included
        missing_cols = list(np.setdiff1d(filter_list, df.columns))
        if not is_fit:
            # We don't care if we're missing the target if we're not
            # currently doing a fit.
            with contextlib.suppress(ValueError):
                missing_cols.remove(target)

        # If explicitly including, we raise an error for missing
        # columns. However for excluding, we simply issue a warning.
        if is_include:
            if missing_cols:
                LOGGER.error(
                    "There are %s missing columns from the data which were explicitly "
                    "specified to be included as input to a transformer",
                    len(missing_cols),
                    extra={"data": missing_cols},
                )
                raise ValueError(f"Missing columns")
            df = df.filter(filter_list, axis="columns")
        else:
            if missing_cols:
                LOGGER.warning(
                    "There are %s missing columns from the data which were explicitly "
                    "specified to be excluded as input to a transformer",
                    len(missing_cols),
                    extra={"data": missing_cols},
                )
            df = df.drop(columns=filter_list, errors="ignore")

    return df


def get_remainder(
    df: pd.DataFrame,
    transformers: Sequence["PandasAbstractTransformer"],
    target: str,
    is_fit: bool,
) -> List[str]:
    """Get the columns which would be the remainder of what would
    have otherwise been accepted by the provided transformers."""
    # First construct an empty dataframe which looks the same as the
    # original dataframe, so filter_df() doesn't consume any memory
    empty_df = pd.DataFrame(columns=df.columns).astype(df.dtypes)
    remaining_cols = set(df.columns)
    for transformer in transformers:
        filtered_df = filter_df(
            empty_df, transformer.input_spec, target=target, is_fit=is_fit
        )
        remaining_cols.difference_update(filtered_df.columns)
    # Use a list comprehension to preserve the order
    return [col for col in df.columns if col in remaining_cols]


class LazilyTransformedDFSequence(Sequence[pd.DataFrame]):
    """A virtual sequence of transformed data-frames, where each data-
    frame is loaded and transformed only when accessed by index or
    iterated over.

    This class is immutable.

    Args:
        dataset: The input dataset to be transformed.
        *transformers: Function(s) which take a data-frame and return a
            transformed one.

    """

    def __init__(
        self,
        dataset: Sequence[pd.DataFrame],
        *transformers: Callable[[pd.DataFrame], pd.DataFrame],
    ) -> None:
        self._dataset = dataset
        self._transformers = list(transformers)

    def add_transformer(
        self, transformer: Callable[[pd.DataFrame], pd.DataFrame]
    ) -> "LazilyTransformedDFSequence":
        """Add a transformer to be lazily run when a data-frame is
        accessed.

        Returns:
            A new LazilyTransformedDFSequence with the new transformer
            added.

        """
        return LazilyTransformedDFSequence(
            self._dataset, *self._transformers, transformer
        )

    def __getitem__(self, index: Union[int, slice]) -> pd.DataFrame:
        df = self._dataset[index]
        for transformer in self._transformers:
            df = transformer(df)
        return df

    def __len__(self) -> int:
        return len(self._dataset)

    # count(), index(), and __contains__() are neglected here. The
    # default implementations of __iter__() and __reversed__() are good
    # enough for this sequence.
