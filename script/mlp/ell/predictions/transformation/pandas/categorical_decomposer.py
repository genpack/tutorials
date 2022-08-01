import logging
from typing import List, Optional, Sequence

import numpy as np
import pandas as pd
from sklearn.exceptions import NotFittedError
from sklearn.preprocessing import OneHotEncoder

from .pandas_transformer_abc import PandasDFAbstractTransformer
from ... import utils

LOGGER = logging.getLogger(__name__)


class Dummifier(PandasDFAbstractTransformer):
    """A One-Hot Encoder.

    This transformer relies on the fitted :class:`pandas.DataFrame`
    to have categorical variables of type
    :class:`pandas.CategoricalDtype`, and for the categories attached to
    each of those dtypes be fully representative of what could appear in
    that variable. The transformer will infer the categories to one-hot
    encode from these categories (i.e. from
    :attr:`pandas.CategoricalDtype.categories`).

    """

    def __init__(self, config: Optional[dict] = None, **kwargs):
        super().__init__(config, **kwargs)
        self._input_features: Optional[List[str]] = None
        self.encoder: Optional[OneHotEncoder] = None

    def _filter_input_df(
        self, df: pd.DataFrame, *, is_fit: bool = False
    ) -> pd.DataFrame:
        df = super()._filter_input_df(df, is_fit=is_fit)
        categoricals = utils.get_categorical_cols(df)
        non_categoricals = df.columns.drop(categoricals).to_list()
        if len(non_categoricals) > 0:
            LOGGER.error(
                "The categorical dummifier has received %s columns which are not of "
                "type `pandas.CategoricalDtype`",
                len(non_categoricals),
                extra={"data": non_categoricals},
            )
            raise TypeError(
                "Expected input to Dummifier to consist of only "
                "categorical columns"
            )
        return df

    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        # Dummifier only needs to be fit on the first
        # batch
        self._fit_df(dataset[0])

    def _fit_df(self, df: pd.DataFrame) -> None:
        self._input_features = df.columns.to_list()
        if not self._input_features:
            LOGGER.warning(
                "Dummifier is being fit to input data with no categorical "
                "variables"
            )
            return
        categories = [
            dtype.categories.to_series().replace(-9999, 9999).sort_values().to_list()
            for dtype in df.dtypes
        ]
        self.encoder = OneHotEncoder(
            categories=categories, sparse=True, dtype=np.bool_, drop="if_binary"
        )
        # This is a slightly hacky way to "fit" the one-hot encoder
        # without actually calling its fit() method.
        # We choose not to use the fit() method because doing so causes
        # the one-hot encoder to essentially discard the categories
        # which we have been explicitly passed in, and infer them from
        # the data. Since we do batch-fitting, it's possible for the
        # data to not include all of the possible categories of each
        # variable.
        self.encoder.categories_ = self.encoder.categories
        self.encoder.drop_idx_ = np.array(
            [0 if len(col_cats) == 2 else None for col_cats in categories]
        )

    def _transform_df(self, df: pd.DataFrame, *, is_fit: bool = False) -> pd.DataFrame:
        if self._input_features is None:
            raise NotFittedError("Dummifier being used before fitting")

        if not self._input_features:
            # In the case where the fitted data contained no categorical
            # variables, we issue a warning during the fit() method and
            # simply return an empty DataFrame in the transform() method
            return df

        original_columns = df.columns

        df = df[self._input_features].replace(-9999, 9999)
        df = pd.DataFrame.sparse.from_spmatrix(
            self.encoder.transform(df),
            index=df.index,
            columns=self.encoder.get_feature_names(self._input_features),
        )
        # Keep original name of binary columns
        cats = self.encoder.categories_
        binary_columns = [
            (column, cats[i][1])
            for i, column in enumerate(self._input_features)
            if len(cats[i]) == 2
        ]
        to_rename = {}
        for column, cat in binary_columns:
            for encoded_column in df.columns:
                if encoded_column == f"{column}_{cat}":
                    to_rename[encoded_column] = column
        df = df.rename(columns=to_rename)
        return self._label_output(df, index=df.index, original_columns=original_columns)
