from typing import Sequence

import pandas as pd

from .pandas_transformer_abc import PandasAbstractTransformer


class Series(PandasAbstractTransformer):
    """A composite transformer which feeds the output of one transformer
    into the next.

    This transformer does not support the ``output`` key.
    """

    def __init__(self, config: dict, **kwargs) -> None:
        super().__init__(config, **kwargs)

        steps = config.get("steps")
        if not steps:
            raise ValueError("Must provide at least one step to a Parallel transformer")

        self.steps = [
            PandasAbstractTransformer.from_config(transformer_cfg)
            for transformer_cfg in steps
        ]
        self.affects_row_count = any(
            transformer.affects_row_count for transformer in self.steps
        )

    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        for transformer in self.steps[:-1]:
            # We do fit_transform on all transformers except for the
            # last one, since we don't actually need to return anything
            dataset = transformer.fit_transform(dataset)
        self.steps[-1].fit(dataset)

    def _transform(
        self, dataset: Sequence[pd.DataFrame], *, is_fit: bool = False
    ) -> Sequence[pd.DataFrame]:
        for transformer in self.steps:
            dataset = transformer.transform(dataset, is_fit=is_fit)
        return dataset

    def _fit_transform(self, dataset: Sequence[pd.DataFrame]) -> Sequence[pd.DataFrame]:
        for transformer in self.steps:
            dataset = transformer.fit_transform(dataset)
        return dataset

    def __repr__(self) -> str:
        return (
            f"{self.__class__.__name__}(parameters{self.parameters!r}, "
            f"steps={self.steps!r})"
        )
