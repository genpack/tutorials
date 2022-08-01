"""
Implementation of lightGBM that inherits from our classifier ABC
"""
import inspect
import logging
from typing import Optional

import pandas as pd

# The following import *must* remain here to enable hist gradient-
# boosting from scikit-learn, since it is an experimental feature. It
# also must go *above* the import for HistGradientBoostingClassifier.
from sklearn.experimental import enable_hist_gradient_boosting  # noqa
from sklearn.ensemble import HistGradientBoostingClassifier

from .pandas_classifier_abc import AbstractPandasClassifier
from ... import utils

LOGGER = logging.getLogger(__name__)


class HistBoostClassifier(AbstractPandasClassifier):
    """
    Histogram-based Gradient Boosted Machine classifier.

    Key parameters and documentation:
    https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.HistGradientBoostingClassifier.html
    """

    WARM_START = True

    DEFAULT_PARAMETERS = dict(
        max_iter=200,
        learning_rate=0.3,
        max_depth=20,
        seed=42,
        validation_fraction=0.2,
        warm_start=True,
    )

    model: HistGradientBoostingClassifier

    def __init__(self, config: Optional[dict] = None) -> None:
        super().__init__(config)
        self.reset()

    def reset(self):
        LOGGER.debug("Initializing model with params", extra={"data": self.parameters})

        params = self.parameters.copy()
        random_state = params.pop("random_state", params.pop("seed"))
        params = utils.trim_params(
            params,
            accepted_params=inspect.signature(
                HistGradientBoostingClassifier
            ).parameters,
        )
        self.model = HistGradientBoostingClassifier(random_state=random_state, **params)

    def _fit(self, X: pd.DataFrame, y):
        self.set_training_seeds()
        X = utils.ensure_dense(X)

        self.model.fit(X, y)

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        X = utils.ensure_dense(X)
        proba = self.model.predict_proba(X)
        proba_df = pd.DataFrame(proba, columns=self.model.classes_, index=X.index)
        return proba_df
