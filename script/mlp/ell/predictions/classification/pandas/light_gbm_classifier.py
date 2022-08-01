"""
Implementation of lightGBM that inherits from our classifier ABC
"""
import csv
import logging
from typing import Dict, List, Optional, Tuple, cast

import numpy as np
import pandas as pd
from ell.env.env_abc import AbstractEnv
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

from ell.predictions import utils

from .pandas_classifier_abc import AbstractPandasClassifier
from ... import compat

LOGGER = logging.getLogger(__name__)

try:
    import lightgbm as lgb
except ModuleNotFoundError:
    lgb = None
except OSError:
    # This can occur where a shared C library (OpenMP) can't be loaded
    # by LightGBM. It tends to occur on AWS Glue, where we can't install
    # said shared library.
    lgb = None
    LOGGER.warning("Could not import LightGBM due to OSError")


class LightGBMClassifier(AbstractPandasClassifier):
    """
    Light Gradient Boosted Machine classifier.

    Key parameters and documentation:
    https://lightgbm.readthedocs.io/en/latest/Parameters.html
    """

    DEFAULT_PARAMETERS = dict(
        early_stopping_test_size=0.25,
        early_stopping_test_randomsplit=True,
        objective="binary",
        early_stopping_rounds=50,
        num_boost_round=20000,
        metric="auc",
        seed=42,
    )

    booster: Optional["lgb.Booster"]
    _evals_result: List[Dict[str, float]]
    _cur_batch: int
    _label_encoder: LabelEncoder

    def __init__(self, config: Optional[dict] = None) -> None:
        if lgb is None:
            raise RuntimeError("LightGBM is not installed!")
        super().__init__(config)
        self.reset()

    def reset(self) -> None:
        LOGGER.debug("Initializing model with params", extra={"data": self.parameters})
        self.booster: Optional[lgb.Booster] = None
        self._evals_result = []
        self._cur_batch = 0
        self._label_encoder = LabelEncoder()

    def _fit(self, X, y):
        params = self.parameters.copy()
        test_size = params.pop("early_stopping_test_size", None)
        random_split = params.pop("early_stopping_test_randomsplit", True)
        verbose = params.pop("verbose", True)

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
                    random_state=params.get("seed"),
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

        LOGGER.info("Creating LightGradientBoosting Dataset for training")
        dtrain = lgb.Dataset(X_train, label=Y_train)

        LOGGER.info("Creating LightGradientBoosting Dataset for testing")
        dtest = lgb.Dataset(X_test, label=Y_test)

        evals_result = {}
        LOGGER.info("Fitting XGB model")
        self.booster = lgb.train(
            params,
            dtrain,
            valid_sets=[dtrain, dtest],
            valid_names=["training", "testing"],
            evals_result=evals_result,
            verbose_eval=verbose,
            init_model=self.booster,
            num_boost_round=params.pop("n_estimators", 10),
            early_stopping_rounds=params.pop("early_stopping_rounds", None),
            keep_training_booster=True,
        )

        # Save evals result by appending to overall evals result, so as
        # to preserve metrics from previous batches
        metric_name = params["metric"]
        self._evals_result.extend(
            {"training": train_metric, "testing": test_metric, "batch": self._cur_batch}
            for train_metric, test_metric in zip(
                evals_result["training"][metric_name],
                evals_result["testing"][metric_name],
            )
        )

        self._cur_batch += 1

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        proba: np.ndarray = self.booster.predict(X)
        classes = self._label_encoder.classes_
        if proba.ndim == 1:
            proba_df = pd.DataFrame(
                {
                    classes[0]: 1 - proba,
                    classes[1]: proba,
                },
                index=X.index,
                columns=classes,
            )
        else:
            proba_df = pd.DataFrame(
                proba,
                index=X.index,
                columns=classes,
            )
        return proba_df

    def save_diagnostics(self, folder_uri: str, env: AbstractEnv = compat.env) -> None:
        """Save train metrics and feature importance for this model."""
        folder_uri = utils.ensure_uri(folder_uri, is_folder=True)

        filesystem = env.get_fs_for_uri(folder_uri)

        LOGGER.info("Saving train metrics for XGB model")
        train_metrics_uri = folder_uri.file("train_metrics.csv")
        with filesystem.open(train_metrics_uri, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=("training", "testing", "batch"))
            writer.writeheader()
            writer.writerows(self._evals_result)

        scores: np.ndarray = self.booster.feature_importance(importance_type="gain")
        feature_importances = sorted(
            zip(self.booster.feature_name(), scores), key=lambda tup: tup[1]
        )
        feature_importances = {
            feature: str(importance) for feature, importance in feature_importances
        }

        LOGGER.info("Saving feature importances for LightGradientBoosting model")
        feature_importance_uri = folder_uri.file("feature_importance.json")
        env.write_jsonish(feature_importance_uri, feature_importances)
