__all__ = ["PandasAbstractTransformer", "PandasDFAbstractTransformer"]

import abc
import functools
import logging
from typing import Sequence, TypeVar, Union

import numpy as np
import pandas as pd

from ._utils import LazilyTransformedDFSequence, filter_df
from ..transformer_abc import AbstractTransformer

LOGGER = logging.getLogger(__name__)

_PandasDatasetType = TypeVar("_PandasDatasetType", pd.DataFrame, Sequence[pd.DataFrame])


class PandasAbstractTransformer(AbstractTransformer, abc.ABC):
    """This class extends :class:`AbstractTransformer` for transformers which
    accept and return Pandas data structures.

    Subclasses of this ABC need to implement the ``_fit()`` method and
    the ``_transform()`` method at a minimum. They may also implement
    the ``_fit_transform()`` method as well, which by default just calls
    ``self._fit(dataset)`` and returns ``self._transform(dataset)``.

    Each of the aforementioned methods accepts a :class:`Sequence` of
    :class:`pandas.DataFrame` objects. EachDataFrame in the sequence is
    a batch of the dataset, and is already filtered according to the
    configuration specified in :attr:`~AbstractTransformer.input_spec`.

    It is up to the transformer how it chooses to handle fitting on
    multiple batches, however all transformers must at least transform
    every batch.

    The ``_filter_input_df()`` method is called on every DataFrame
    coming into the transformer (for fitting or transformation), and
    thus subclasses can override this method to perform any input
    validation. See the implementation of this method on the
    :class:`TargetEncoder` for an example.

    The ``_label_output()`` method is also available for subclasses as a
    helper to label the output columns as specified by
    :attr:`~AbstractTransformer.output_spec`. This method is not called
    anywhere by this base class, so each implementation must call it
    individually. It has the capability of modifying the existing labels
    of a :class:`pandas.DataFrame`, or applying labels to a
    :class:`numpy.ndarray`, or appropriately reshaping a
    :class:`pandas.Series` (or a 1-dimensional :class:`numpy.ndarray`)
    into a :class:`pandas.DataFrame`. When calling this method, you must
    also provide the index of the DataFrame to be returned, and the
    *original* columns which your transformer received.

    """

    def fit(self, dataset: _PandasDatasetType) -> None:
        """Fit the transformer to the given input samples.

        Args:
            dataset (pandas.DataFrame or Sequence[pandas.DataFrame]):
                The dataset (possibly batched) to fit the transformer
                to.

        """
        dataset = self._filter_input(dataset, is_fit=True)
        if isinstance(dataset, pd.DataFrame):
            dataset = [dataset]

        self._fit(dataset)

    def transform(
        self, dataset: _PandasDatasetType, *, is_fit: bool = False
    ) -> _PandasDatasetType:
        """Transform the input samples.

        Args:
            dataset (pandas.DataFrame or Sequence[pandas.DataFrame]):
                The dataset (possibly batched) to transform.
            is_fit (bool): Should be `True` when the dataset is the one
                the model is being trained on.

        Returns:
            Same data-type as was passed in. The transformed dataset. If
            the input dataset was a sequence, the dataset will be
            transformed lazily.

        """
        dataset = self._filter_input(dataset, is_fit=is_fit)
        batched = not isinstance(dataset, pd.DataFrame)
        if not batched:
            dataset = [dataset]

        dataset = self._transform(dataset, is_fit=is_fit)
        if batched:
            return dataset
        else:
            return dataset[0]

    def fit_transform(self, dataset: _PandasDatasetType) -> _PandasDatasetType:
        """Fit and transform the input samples in one operation.

        For some transformers, this method may be more efficient than
        separate :meth:`~PandasAbstractTransformer.fit` and
        :meth:`~PandasAbstractTransformer.transform` calls.
        """
        dataset = self._filter_input(dataset, is_fit=True)
        batched = not isinstance(dataset, pd.DataFrame)
        if not batched:
            dataset = [dataset]

        dataset = self._fit_transform(dataset)
        if batched:
            return dataset
        else:
            return dataset[0]

    def _filter_input(
        self, dataset: _PandasDatasetType, *, is_fit: bool = False
    ) -> _PandasDatasetType:
        """Filter the input samples based on the
        :attr:`~AbstractTransformer.input_spec`.

        Args:
            dataset (pandas.DataFrame or Sequence[pandas.DataFrame]):
                The dataset (possibly batched) to filter.
            is_fit (bool): Should be `True` when the dataset is the one
                the model is being trained on.

        Returns:
            Same data-type as was passed in. The filtered dataset. If
            the input dataset was a sequence, the dataset will be
            transformed lazily.

        """
        filterer = functools.partial(self._filter_input_df, is_fit=is_fit)
        if isinstance(dataset, pd.DataFrame):
            dataset = filterer(dataset)
        elif isinstance(dataset, LazilyTransformedDFSequence):
            dataset = dataset.add_transformer(filterer)
        else:
            dataset = LazilyTransformedDFSequence(dataset, filterer)
        return dataset

    def _filter_input_df(
        self, df: pd.DataFrame, *, is_fit: bool = False
    ) -> pd.DataFrame:
        """Same as :meth:`~PandasAbstractTransformer._filter_input` but
        eagerly operates on a single dataframe only.
        """
        return filter_df(df, self.input_spec, target=self._target, is_fit=is_fit)

    @abc.abstractmethod
    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        """Fit the transformer to the given input samples.

        Subclasses **must** implement this method. The input samples are
        already filtered (by
        :meth:`~PandasAbstractTransformer._filter_input`) and the dataset is
        *always* a sequence, to simplify implementation.
        """
        raise NotImplementedError

    @abc.abstractmethod
    def _transform(
        self, dataset: Sequence[pd.DataFrame], *, is_fit: bool = False
    ) -> Sequence[pd.DataFrame]:
        """Transform the given input samples.

        Subclasses **must** implement this method. The input samples are
        already filtered (by
        :meth:`~PandasAbstractTransformer._filter_input`) and the dataset is
        *always* a sequence, to simplify implementation.
        """
        raise NotImplementedError

    def _fit_transform(self, dataset: Sequence[pd.DataFrame]) -> Sequence[pd.DataFrame]:
        """Fit and transform the input samples in one operation.

        Subclasses **can** implement this method if it would be a more
        efficient operation than separate
        :meth:`~PandasAbstractTransformer.fit` and
        :meth:`~PandasAbstractTransformer.transform` calls. The input samples
        are already filtered (by
        :meth:`~PandasAbstractTransformer._filter_input`) and the dataset is
        *always* a sequence, to simplify implementation.
        """
        self._fit(dataset)
        return self._transform(dataset, is_fit=True)

    def _label_output(
        self,
        data: Union[pd.DataFrame, pd.Series, np.ndarray],
        index: pd.Index,
        original_columns: pd.Index,
    ) -> pd.DataFrame:
        """A helper function to apply the
        :attr:`~AbstractTransformer.output_spec` to the transformed
        data-frame, and coerce it into a :class:`pandas.DataFrame`.

        This method is **not automatically called anywhere** by this
        class, and so implementations must call it themselves.

        Args:
            data: The transformed dataset. If one-dimensional, it will
                be coerced into a 2-dimensional data-frame with a single
                column.
            index: The index to apply to the data-frame. This argument
                is always required, however it will only actually be
                used if the data is a :class:`numpy.ndarray`.
            original_columns: The original columns of the input samples.
                This is used if the user has specified that the original
                column names should be preserved in the output of the
                transformer.

        """
        if isinstance(data, pd.DataFrame) and not self.output_spec:
            # If there's no output spec and the columns are already
            # labelled by the transformer, we don't touch the column
            # names
            return data.sort_index(axis=1)

        # Convert any 1-dimensional things to 2-dimensional
        if isinstance(data, pd.Series):
            data = data.to_frame()
        elif isinstance(data, np.ndarray) and data.ndim == 1:
            data = data.reshape(data.shape[0], 1)

        column_names = self.output_spec.get("column_names", {})
        if isinstance(column_names, list):
            if len(column_names) != data.shape[1]:
                raise ValueError(
                    f"{self}: Specified number of output column names "
                    f"({len(column_names)}) does not match number of transformed "
                    f"columns ({data.shape[1]})"
                )
            new_column_names = column_names
        elif column_names.get("keep_original"):
            if len(original_columns) != data.shape[1]:
                raise ValueError(
                    f"{self}: Cannot keep the original column names since the number "
                    f"of columns has changed after transformation"
                )
            new_column_names = original_columns.to_list()
        elif isinstance(data, pd.DataFrame):
            # Assume we are keeping the columns applied by the
            # transformer itself
            new_column_names = data.columns.to_list()
        else:
            new_column_names = list(map(str, range(data.shape[1])))

        prefix = self.output_spec.get("column_name_prefix")
        if prefix is not None:
            new_column_names = [
                f"{prefix}_{column_name}" for column_name in new_column_names
            ]

        suffix = self.output_spec.get("column_name_suffix")
        if suffix is not None:
            new_column_names = [
                f"{column_name}_{suffix}" for column_name in new_column_names
            ]

        if isinstance(data, pd.DataFrame):
            df = data.rename(columns=dict(zip(data.columns, new_column_names)))
        else:
            df = pd.DataFrame(data, columns=new_column_names, index=index)

        return df.sort_index(axis=1)


class PandasDFAbstractTransformer(PandasAbstractTransformer):
    """This class extends :class:`PandasAbstractTransformer` to make it
    easier to implement transformers which need to deal with batches
    individually (this applies to most Pandas transformers).

    A subclass only needs to implement two methods:

    1. ``_fit_df()``, which is called once per batch of the dataset, and
    2. ``_transform_df()``, which is called once per batch of the
       dataset, and should return the transformed version of that batch.

    This class also performs some magic to make conducting a pipeline of
    transformers more memory efficient - specifically, the
    transformation of data is done **lazily**. The returned Sequence of
    DataFrames does not actually hold the transformed DataFrames in
    memory - instead, each time a batch of the returned DataFrame is
    "accessed" (either via square-bracket indexing or iteration), this
    transformer accesses the corresponding untransformed DataFrame
    (which may in-turn be lazily transformed, or lazily loaded from
    disk), and passes it through ``_transform_df()``.

    Fitting, on the other hand, is done eagerly. Some subclasses may
    wish to override the ``_fit()`` method if they only wish to call
    ``_fit_df()`` on the first batch of the dataset, or something like
    that (see the implementation of ``_fit()`` in
    :class:`Dummifier` for an example of this).
    Alternatively, if the transformer does not require fitting, it
    should override the ``_fit()`` method to do nothing, since if you
    only implement the ``_fit_df()`` method, it will still be called
    with each batch of the dataset, and since the dataset is lazily
    loaded / transformed, this may be an unnecessarily expensive
    operation (see :class:`UnitTransformer` for an example of this).

    """

    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        for df in dataset:
            self._fit_df(df)

    def _transform(
        self, dataset: Sequence[pd.DataFrame], *, is_fit: bool = False
    ) -> Sequence[pd.DataFrame]:
        transformer = functools.partial(self._transform_df, is_fit=is_fit)

        if isinstance(dataset, LazilyTransformedDFSequence):
            dataset = dataset.add_transformer(transformer)
        else:
            dataset = LazilyTransformedDFSequence(dataset, transformer)
        return dataset

    @abc.abstractmethod
    def _fit_df(self, df: pd.DataFrame) -> None:
        """Fit a batch of the input samples to the transformer.

        This is a helper method so that subclasses don't have to all
        iterate over the batches in the input samples, and only have to
        deal with data-frames.
        """
        raise NotImplementedError

    @abc.abstractmethod
    def _transform_df(self, df: pd.DataFrame, *, is_fit: bool = False) -> pd.DataFrame:
        """Transform a batch of the input samples.

        This is a helper method so that subclasses don't have to all
        iterate over the batches in the input samples, and only have to
        deal with data-frames. Also, by implementing just this method
        and not :meth:`~PandasAbstractTransformer._transform`, the "lazy"
        behaviour of transformers is performed automatically (i.e. this
        method will be called lazily, possibly multiple times per batch,
        so this method should ideally be idempotent).
        """
        raise NotImplementedError
