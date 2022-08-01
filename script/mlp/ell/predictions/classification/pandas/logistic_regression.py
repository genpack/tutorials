"""
Implementation of sklearn logistic regression with walk-backwards feature selection. Inherits from our classifier ABC
"""
import inspect
import logging
from typing import List, Optional

import pandas as pd
from ell.env.env_abc import AbstractEnv
from sklearn.linear_model import LogisticRegression

from .pandas_classifier_abc import AbstractPandasClassifier
from ... import compat, utils

LOGGER = logging.getLogger(__name__)


class LogisticRegressionClassifier(AbstractPandasClassifier):
    """ "
    Logistic Regression classifier.
    There are two approaches -  libSVM and SGD

    Key parameters and documentation:
    https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.LogisticRegression.html

    See warm start vs partial fit - i.e. use fit only with warm start
    https://stackoverflow.com/questions/38052342/what-is-the-difference-between-partial-fit-and-warm-start

    """

    WARM_START = True
    DEFAULT_PARAMETERS = dict(
        random_state=42,
        penalty="l2",
        verbose=1,
        fit_intercept=True,
        warm_start=True,
    )
    model: LogisticRegression

    def __init__(self, config: Optional[dict] = None) -> None:
        super().__init__(config)
        self._features: Optional[List[str]] = None
        self.reset()

    def reset(self):
        """Initialize LR model."""
        LOGGER.debug("Initializing model with params", extra={"data": self.parameters})

        params = utils.trim_params(
            self.parameters,
            accepted_params=inspect.signature(LogisticRegression).parameters,
        )
        self.model = LogisticRegression(**params)
        self._features: Optional[List[str]] = None

    def _fit(self, X: pd.DataFrame, y: pd.Series) -> None:
        if self._features is None:
            self._features = X.columns.to_list()
        self.model.fit(X, y)

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        proba = self.model.predict_proba(X)
        proba_df = pd.DataFrame(proba, columns=self.model.classes_, index=X.index)
        return proba_df

    def save_diagnostics(self, folder_uri: str, env: AbstractEnv = compat.env) -> None:
        """Save feature importances for this classifier.

        The feature importances are simply the coefficicents for each
        variable in the LogisticRegression model.
        """
        folder_uri = utils.ensure_uri(folder_uri, is_folder=True)

        scores_dict = {
            feature: list(importance)
            for feature, importance in zip(
                self._features,
                self.model.coef_.T,
            )
        }

        LOGGER.info("Saving feature importances for LogisticRegression model")
        feature_importance_uri = folder_uri.file("feature_importance.json")
        env.write_jsonish(feature_importance_uri, scores_dict)
