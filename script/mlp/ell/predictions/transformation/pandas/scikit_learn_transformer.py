import logging
from typing import Sequence

import pandas as pd

from .pandas_transformer_abc import PandasDFAbstractTransformer
from ... import utils

LOGGER = logging.getLogger(__name__)


class ScikitLearnTransformer(PandasDFAbstractTransformer):
    def __init__(self, config: dict, **kwargs) -> None:
        super().__init__(config, **kwargs)
        import_path = config["import_path"]
        self.transformer = utils.import_and_call(import_path, **self.parameters)
        self._do_xy_split = bool(config.get("do_xy_split"))

    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        # Transformers which can't be partially fit are only fit on
        # the first batch.
        if not hasattr(self.transformer, "partial_fit"):
            if len(dataset) > 1:
                LOGGER.warning(
                    "The Scikit-Learn transformer %r does not support batch fitting, "
                    "and there are %s batches in the dataset. The transformer will "
                    "only be fit on the first batch",
                    type(self.transformer).__name__,
                    len(dataset),
                )
            self._fit_df(dataset[0])
        else:
            super()._fit(dataset)

    def _fit_df(self, df: pd.DataFrame) -> None:
        fit_func = getattr(self.transformer, "partial_fit", self.transformer.fit)

        if self._do_xy_split:
            X = df.drop(columns=[self._target])
            y = df[self._target]
            fit_func(X, y)
        else:
            fit_func(df)

    def _transform_df(self, df: pd.DataFrame, *, is_fit=False) -> pd.DataFrame:
        original_columns = df.columns
        if self._do_xy_split and self._target in df.columns:
            X = df.drop(columns=[self._target])
            original_columns = original_columns.drop(self._target)
            data = self.transformer.transform(X)
        else:
            data = self.transformer.transform(df)

        return self._label_output(
            data, index=df.index, original_columns=original_columns
        )

    def __repr__(self) -> str:
        return (
            f"{self.__class__.__name__}(transformer={self.transformer!r}, "
            f"parameters={self.parameters!r})"
        )
