import logging
from typing import Optional, Sequence

import pandas as pd
from sklearn.cluster import KMeans

from .pandas_transformer_abc import PandasDFAbstractTransformer

LOGGER = logging.getLogger(__name__)


class KMeansTransformer(PandasDFAbstractTransformer):
    def __init__(self, config: Optional[dict] = None, **kwargs) -> None:
        super().__init__(config, **kwargs)
        self.kmeans = KMeans(**self.parameters)

    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        if len(dataset) > 1:
            LOGGER.warning(
                "KMeansTransformer cannot fit on multiple batches yet! Only the first "
                "batch will be used to train the transformer"
            )

        self._fit_df(dataset[0])

    def _fit_df(self, df: pd.DataFrame) -> None:
        self.kmeans.fit(df)

    def _transform_df(self, df: pd.DataFrame, *, is_fit: bool = False) -> pd.DataFrame:
        data = self.kmeans.predict(df)
        return self._label_output(data, index=df.index, original_columns=df.columns)
