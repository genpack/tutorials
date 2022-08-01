import logging
from typing import Sequence

import numpy as np
import pandas as pd

from .pandas_transformer_abc import PandasDFAbstractTransformer

LOGGER = logging.getLogger(__name__)


class ClassifierAsTransformer(PandasDFAbstractTransformer):
    """
    Wrapper to use any Pandas-based classifier defined in
    :mod:`ell.predictions.classification` as a
    transformer.
    """

    def __init__(self, config: dict, **kwargs) -> None:
        """Constructor for this transformer."""
        super().__init__(config, **kwargs)

        # Import locally to avoid circular import
        from ell.predictions.classification import AbstractPandasClassifier

        classifier_type = config["classifier_type"]
        classifier_params = self.parameters.copy()
        classifier_params.pop("logit", None)

        self.classifier = AbstractPandasClassifier.from_config(
            config=dict(
                type=classifier_type, parameters=classifier_params, target=self._target
            )
        )

    def _fit(self, dataset: Sequence[pd.DataFrame]) -> None:
        """Fit the classifier."""
        self.classifier.fit(dataset)

    def _fit_df(self, df: pd.DataFrame) -> None:
        # This method is never called because we override _fit()
        pass

    def _transform_df(self, df: pd.DataFrame, *, is_fit: bool = False) -> pd.DataFrame:
        proba_df, cats_df = self.classifier.predict(df)

        if proba_df.shape[1] == 2:
            # In binary classification we discard the probability for
            # the negative case
            proba_df = proba_df.iloc[:, [1]]

        # Do forward logit transformation to convert probabilities to logits
        if self.parameters.get("logit"):
            proba_df = self.forward_logit(proba_df)

        return self._label_output(proba_df, index=df.index, original_columns=df.columns)

    @staticmethod
    def forward_logit(df: pd.DataFrame) -> pd.DataFrame:
        """The logit function. It takes probabilities between 0 and 1,
        and maps it to a number between -inf and +inf.
        """
        # Define smallest number where np.log(number) != -inf
        epsilon = np.finfo(float).eps
        upper_epsilon = 1 - epsilon

        # Anything close to zero or 1 set to epsilon (or else log will make -infs or
        # +infs).
        # noinspection PyTypeChecker
        df = df.mask(df < epsilon, epsilon).mask(df > upper_epsilon, upper_epsilon)

        # Apply the logit function to each column of the DataFrame.
        df = df.apply(lambda p: np.log(p / (1 - p)), axis="rows")

        return df
