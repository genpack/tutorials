import logging
from copy import deepcopy
from typing import Dict, Hashable, Optional, cast

import numpy as np
import pandas as pd

from .pandas_transformer_abc import PandasDFAbstractTransformer
from ... import utils

LOGGER = logging.getLogger(__name__)


class TargetEncoder(PandasDFAbstractTransformer):
    DEFAULT_PARAMETERS = dict(
        min_samples_leaf=1,
        smoothing=1.0,
    )

    def __init__(self, config: Optional[dict] = None, **kwargs) -> None:
        super().__init__(config, **kwargs)
        self._stats = {}
        self._count = 0
        self._prior = -1
        self._mapping: Optional[Dict[str, Dict[Hashable, float]]] = None

    def get_mapping(self) -> Dict[str, Dict[Hashable, float]]:
        # Return a copy to prevent mutation
        return deepcopy(self._mapping)

    def _filter_input_df(
        self, df: pd.DataFrame, *, is_fit: bool = False
    ) -> pd.DataFrame:
        df = super()._filter_input_df(df, is_fit=is_fit)
        if is_fit and self._target not in df.columns:
            raise ValueError(
                f"TargetEncoder did not receive the target column "
                f"({self._target}) in the input"
            )

        categoricals = utils.get_categorical_cols(df)
        non_categoricals = (
            df.columns.drop(self._target, errors="ignore").drop(categoricals).to_list()
        )
        if non_categoricals:
            LOGGER.error(
                "The target encoder has received %s columns which are not of type "
                "`pandas.CategoricalDtype`",
                len(non_categoricals),
                extra={"data": non_categoricals},
            )
            raise TypeError(
                "Expected input to TargetEncoder to consist of only categorical columns"
            )
        return df

    def _fit_df(self, df: pd.DataFrame) -> None:
        X = df.drop(columns=[self._target])
        y = df[self._target]

        prev_prior = self._prior
        prev_count = self._count

        prior = y.mean()
        count = y.shape[0]
        new_count = count + prev_count

        self._prior = ((prior * count) + (prev_prior * prev_count)) / new_count
        self._count = new_count

        self._update_stats(X, y)
        self._update_mapping()

    def _transform_df(self, df: pd.DataFrame, *, is_fit: bool = False) -> pd.DataFrame:
        original_columns = df.columns
        df = df.drop(columns=[self._target], errors="ignore").replace(self._mapping)
        return self._label_output(df, index=df.index, original_columns=original_columns)

    def _update_stats(self, X: pd.DataFrame, y: pd.Series) -> None:
        stats = deepcopy(self._stats)

        for col, series in X.iteritems():
            col_stats = stats.setdefault(col, {})
            stats_df = y.groupby(series).agg(["count", "mean"])
            dtype = cast(pd.CategoricalDtype, series.dtype)
            for category in dtype.categories:
                cat_stats = col_stats.setdefault(
                    category, {"count": 0, "mean": self._prior}
                )

                if category not in stats_df.index:
                    continue
                count, mean = stats_df.loc[category]

                prev_count = cat_stats["count"]
                prev_mean = cat_stats["mean"]

                new_count = count + prev_count
                new_mean = ((prev_count * prev_mean) + (count * mean)) / new_count

                cat_stats["count"] = new_count
                cat_stats["mean"] = new_mean

        self._stats = stats

    def _update_mapping(self) -> None:
        mapping = {}
        min_samples_leaf = self.parameters["min_samples_leaf"]
        smoothing = self.parameters["smoothing"]
        for col, col_stats in self._stats.items():
            mapping[col] = col_mapping = {}
            for cat, cat_stats in col_stats.items():
                count = cat_stats["count"]
                mean = cat_stats["mean"]

                if count <= 1:
                    value = self._prior
                else:
                    smoove = 1 / (1 + np.exp(-(count - min_samples_leaf) / smoothing))
                    value = self._prior * (1 - smoove) + mean * smoove

                col_mapping[cat] = value

        self._mapping = mapping
