from typing import Sequence

import pandas as pd

from .pandas_transformer_abc import PandasDFAbstractTransformer


class UnitTransformer(PandasDFAbstractTransformer):
    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        pass

    def _fit_df(self, df: pd.DataFrame) -> None:
        # This method is never called because we override _fit()
        pass

    def _transform(
        self, dataset: Sequence[pd.DataFrame], *, is_fit: bool = False
    ) -> Sequence[pd.DataFrame]:
        if not self.output_spec:
            # Nothing to change in the output - simply return the input
            return dataset

        return super()._transform(dataset)

    def _transform_df(self, df: pd.DataFrame, *, is_fit: bool = False) -> pd.DataFrame:
        return self._label_output(df, index=df.index, original_columns=df.columns)
