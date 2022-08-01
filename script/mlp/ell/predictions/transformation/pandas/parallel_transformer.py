import logging
from typing import Sequence

import pandas as pd

from ._utils import get_remainder
from .pandas_transformer_abc import PandasDFAbstractTransformer, PandasAbstractTransformer

LOGGER = logging.getLogger(__name__)


class Parallel(PandasDFAbstractTransformer):
    """A composite transformer which runs multiple transformers side-by-
    side and joins the output together (column-wise).
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

        forbidden_transformers = [
            transformer for transformer in self.steps if transformer.affects_row_count
        ]
        if forbidden_transformers:
            raise ValueError(
                f"The following transformers cannot be put inside a Parallel "
                f"transformer, as they may affect the row count of transformed "
                f"DataFrames: {', '.join(map(repr, forbidden_transformers))}"
            )
        if any(
            transformer.input_spec.get("remainder") for transformer in self.steps[:-1]
        ):
            raise ValueError(
                f"Only the last step of a Parallel transformer may ask for 'remainder' "
                f"as the input"
            )

    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        for idx, transformer in enumerate(self.steps):

            # Set the input spec for the last transformer if it asks for
            # the "remainder"
            if idx == len(self.steps) - 1 and transformer.input_spec.get("remainder"):
                cols = get_remainder(
                    dataset[0],
                    transformers=self.steps[:-1],
                    target=self._target,
                    is_fit=True,
                )
                transformer.input_spec = {"include": cols}

            transformer.fit(dataset)

    def _fit_df(self, df: pd.DataFrame) -> None:
        # This method is never called because we override _fit()
        pass

    def _transform_df(self, df: pd.DataFrame, *, is_fit=False) -> pd.DataFrame:
        original_columns = df.columns
        original_index = df.index

        output_df = pd.DataFrame(index=df.index)
        for transformer in self.steps:
            transformed_df = transformer.transform(df, is_fit=is_fit)

            if df.shape[0] != transformed_df.shape[0]:
                raise RuntimeError(
                    f"The transformer {transformer} changed the row count of the "
                    f"DataFrame! Since the transformer is a step in a Parallel "
                    f"transformer, this is a critical error"
                )

            output_df = output_df.join(transformed_df, how="inner")

            num_dropped = df.shape[0] - output_df.shape[0]
            if num_dropped > 0:
                raise RuntimeError(
                    f"The transformer {transformer} caused {num_dropped} (of "
                    f"{df.shape[0]}) rows to be dropped when joining back to the "
                    f"original index"
                )

        return self._label_output(
            output_df, index=original_index, original_columns=original_columns
        )

    def __repr__(self) -> str:
        return (
            f"{self.__class__.__name__}(parameters{self.parameters!r}, "
            f"steps={self.steps!r})"
        )
