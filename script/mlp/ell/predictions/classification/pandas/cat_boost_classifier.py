"""
Implementation of catBoost that inherits from our classifier ABC
"""

import logging
from inspect import signature
from typing import Optional, Tuple, cast

import catboost
import numpy as np
import pandas as pd
from ell.env.env_abc import AbstractEnv
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

from .pandas_classifier_abc import AbstractPandasClassifier
from ... import compat, utils

LOGGER = logging.getLogger(__name__)


class CatBoostClassifier(AbstractPandasClassifier):
    """
    Catboost classifier.

    Key parameters and documentation:
    https://catboost.ai/docs/concepts/python-reference_parameters-list.html
    """

    DEFAULT_PARAMETERS = dict(
        early_stopping_test_size=0.25,
        early_stopping_test_randomsplit=True,
        use_categoricals=True,
        seed=42,
        loss_function="Logloss",
        od_type="Iter",
        od_wait=50,
        iterations=2000,
        verbose=100,
        eval_metric="AUC",
    )

    model: catboost.CatBoostClassifier
    _label_encoder: LabelEncoder

    def __init__(self, config: Optional[dict] = None):
        super().__init__(config)
        self.reset()

    def reset(self) -> None:
        LOGGER.debug("Initializing model with params", extra={"data": self.parameters})
        params = self.parameters.copy()
        params.pop("use_categoricals", None)
        params.pop("early_stopping_test_size", None)
        params.pop("early_stopping_test_randomsplit", None)
        random_seed = params.pop("random_seed", params.pop("seed", None))
        params = utils.trim_params(
            params, accepted_params=signature(catboost.CatBoostClassifier).parameters
        )
        self.model = catboost.CatBoostClassifier(**params, random_seed=random_seed)
        self._label_encoder = LabelEncoder()

    def _fit(self, X: pd.DataFrame, y: pd.Series) -> None:
        use_categoricals = self.parameters.get("use_categoricals", True)
        test_size = self.parameters.get("early_stopping_test_size", None)
        random_split = self.parameters.get("early_stopping_test_randomsplit", True)
        random_seed = self.parameters.get("seed", None)

        if use_categoricals:
            cat_features = utils.get_categorical_cols(X)
        else:
            cat_features = []

        LOGGER.debug(
            "Shapes going into split", extra={"data": {"X": X.shape, "y": y.shape}}
        )
        if random_split:
            X_train, X_test, Y_train, Y_test = cast(
                Tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series],
                train_test_split(
                    X,
                    y,
                    stratify=y,
                    test_size=test_size,
                    random_state=random_seed,
                ),
            )
        else:
            LOGGER.info("Doing a contiguous train-test split to save memory")
            test_size = int(test_size * X.shape[0])
            X_train, X_test = X.iloc[:-test_size], X.iloc[-test_size:]
            Y_train, Y_test = y.iloc[:-test_size], y.iloc[-test_size:]
        LOGGER.debug(
            "Shapes coming out of split",
            extra={
                "data": {
                    "X_train": X_train.shape,
                    "X_test": X_test.shape,
                    "Y_train": Y_train.shape,
                    "Y_test": Y_test.shape,
                }
            },
        )

        LOGGER.debug("Encoding classes")
        self._label_encoder.fit(Y_train)
        Y_train = self._label_encoder.transform(Y_train)
        Y_test = self._label_encoder.transform(Y_test)

        LOGGER.info("Creating CatBoost Pool for train dataset")
        dtrain = catboost.Pool(X_train, label=Y_train, cat_features=cat_features)

        LOGGER.info("Creating CatBoost Pool for test dataset")
        dtest = catboost.Pool(X_test, label=Y_test, cat_features=cat_features)

        if self.model.is_fitted():
            init_model = self.model.copy()
        else:
            init_model = None

        LOGGER.info("Fitting CatBoost model")
        self.model.fit(
            dtrain,
            eval_set=dtest,
            init_model=init_model,
        )
        LOGGER.info("Finished fitting CatBoost model")

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        if self.parameters["use_categoricals"]:
            cat_features = utils.get_categorical_cols(X)
        else:
            cat_features = []

        data = catboost.Pool(X, cat_features=cat_features)
        proba: np.ndarray = self.model.predict_proba(data)
        proba_df = pd.DataFrame(
            proba,
            index=X.index,
            columns=self._label_encoder.classes_,
        )
        return proba_df

    def save_diagnostics(self, folder_uri: str, env: AbstractEnv = compat.env):
        """Save the feature importance for the CatBoost model."""
        folder_uri = utils.ensure_uri(folder_uri, is_folder=True)

        scores_list = list(
            zip(self.model.feature_names_, self.model.get_feature_importance())
        )
        scores_list.sort(key=lambda tup: tup[1])
        scores_dict = {feature: str(importance) for feature, importance in scores_list}

        LOGGER.info("Saving feature importances for CatBoost model")
        feature_importance_uri = folder_uri.file("feature_importance.json")
        env.write_jsonish(feature_importance_uri, scores_dict)
