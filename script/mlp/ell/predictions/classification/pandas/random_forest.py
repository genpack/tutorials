"""
Implementation of Random Forest that inherits from our classifier ABC
"""
import inspect
import logging
from typing import List, Optional

import pandas as pd
from ell.env.env_abc import AbstractEnv
from sklearn.ensemble import RandomForestClassifier as SklearnRandomForestClassifier

from .pandas_classifier_abc import PandasAbstractClassifier
from ... import compat, utils

LOGGER = logging.getLogger(__name__)


class RandomForestClassifier(AbstractPandasClassifier):
    """
    Random forest classifier.

    Key parameters and documentation:
    https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html
    """

    WARM_START = True
    DEFAULT_PARAMETERS = dict(
        warm_start=True,
        random_state=42,
        max_depth=6,
        n_estimators=100,
        n_jobs=4,
        verbose=1,
    )

    model: SklearnRandomForestClassifier

    def __init__(self, config: Optional[dict] = None):
        super().__init__(config)
        self.reset()
        self._features: Optional[List[str]] = None

    def reset(self):
        LOGGER.debug("Initializing model with params", extra={"data": self.parameters})
        params = self.parameters.copy()
        params = utils.trim_params(
            params,
            accepted_params=inspect.signature(SklearnRandomForestClassifier).parameters,
        )
        self.model = SklearnRandomForestClassifier(**params)
        self._features: Optional[List[str]] = None

    def _fit(self, X: pd.DataFrame, y: pd.Series) -> None:
        if self._features is None:
            self._features = X.columns.to_list()
        self.model.fit(X, y)

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        proba = self.model.predict_proba(X)
        return pd.DataFrame(proba, index=X.index, columns=self.model.classes_)

    def save_diagnostics(self, folder_uri: str, env: AbstractEnv = compat.env) -> None:
        """Save the feature importance for the RandomForest model."""
        folder_uri = utils.ensure_uri(folder_uri, is_folder=True)

        feature_importances = list(zip(self._features, self.model.feature_importances_))
        feature_importances.sort(key=lambda tup: tup[1])
        feature_importances = {
            feature: str(score) for feature, score in feature_importances
        }

        LOGGER.info("Saving feature importances for RandomForest model")
        feature_importance_uri = folder_uri.file("feature_importance.json")
        env.write_jsonish(feature_importance_uri, feature_importances)
