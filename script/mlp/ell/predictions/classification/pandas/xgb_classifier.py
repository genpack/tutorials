"""
Implementation of xgboost that inherits from our classifier ABC
"""
import csv
import logging
from typing import Dict, List, Optional, Tuple, cast

import numpy as np
import pandas as pd
from ell.env.env_abc import AbstractEnv
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

from .pandas_classifier_abc import AbstractPandasClassifier
from ... import compat, utils

try:
    import xgboost as xgb
except ModuleNotFoundError:
    xgb = None

LOGGER = logging.getLogger(__name__)


class XGBClassifier(AbstractPandasClassifier):
    """XGB classifier.

    Key parameters and documentation:
    https://xgboost.readthedocs.io/en/latest/parameter.html
    """

    WARM_START = True
    DEFAULT_PARAMETERS = dict(
        early_stopping_test_size=0.3,
        early_stopping_test_randomsplit=True,
        booster="gbtree",
        objective="binary:logistic",
        eval_metric="logloss",
        eta=0.3,
        gamma=0.1,
        max_depth=6,
        min_child_weight=1,
        max_delta_step=0,
        subsws07le=1,
        colsample_bytree=1,
        seed=0,
        base_score=0.5,
        scale_pos_weight=1,
        missing=-9999.0,
    )

    booster: Optional["xgb.Booster"]
    _evals_result: List[Dict[str, float]]
    _cur_batch: int
    _label_encoder: LabelEncoder

    def __init__(self, config: Optional[dict] = None) -> None:
        if xgb is None:
            raise RuntimeError("XGB is not installed!")
        super().__init__(config)
        self.reset()

    def reset(self):
        LOGGER.debug("Initializing model with params", extra={"data": self.parameters})

        self.booster = None
        self._evals_result = []
        self._cur_batch = 0
        self._label_encoder = LabelEncoder()

    def _fit(self, X: pd.DataFrame, y: pd.Series):
        """Fit model - assumes warm start."""
        params = self.parameters.copy()
        test_size = params.pop("early_stopping_test_size", None)
        random_split = params.pop("early_stopping_test_randomsplit", True)
        missing = params.pop("missing", -9999.0)
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

        feature_names = []
        feature_types = []
        for col, dtype in X_train.dtypes.iteritems():
            feature_names.append(col)
            if isinstance(dtype, pd.SparseDtype):
                dtype = dtype.subtype
            if pd.api.types.is_categorical_dtype(dtype):
                dtype = dtype.categories.dtype
            if dtype.kind == "f":
                feature_types.append("float")
            elif dtype.kind == "i":
                feature_types.append("int")
            elif dtype.kind == "b":
                feature_types.append("i")
            else:
                raise TypeError(f"Unknown type kind for column {col}: {dtype.kind}")
        LOGGER.debug(
            "Feature names and types for X DMatrices",
            extra={"data": dict(zip(feature_names, feature_types))},
        )

        LOGGER.info("Creating XGB DMatrix for train dataset")
        dtrain = xgb.DMatrix(
            X_train.to_numpy("float32", copy=False),
            label=Y_train,
            feature_names=feature_names,
            feature_types=feature_types,
            missing=missing,
        )

        LOGGER.info("Creating XGB DMatrix for test dataset")
        dtest = xgb.DMatrix(
            X_test.to_numpy("float32", copy=False),
            label=Y_test,
            feature_names=feature_names,
            feature_types=feature_types,
            missing=missing,
        )

        evals = [(dtrain, "training"), (dtest, "testing")]
        evals_result = {}
        LOGGER.info("Fitting XGB model")
        self.booster = xgb.train(
            params,
            dtrain,
            evals=evals,
            evals_result=evals_result,
            verbose_eval=verbose,
            xgb_model=self.booster,
            num_boost_round=params.pop("n_estimators", 10),
            early_stopping_rounds=params.pop("early_stopping_rounds", None),
        )

        # Save evals result by appending to overall evals result, so as
        # to preserve metrics from previous batches
        metric_name = params.get("eval_metric", "logloss")
        self._evals_result.extend(
            {"training": train_metric, "testing": test_metric, "batch": self._cur_batch}
            for train_metric, test_metric in zip(
                evals_result["training"][metric_name],
                evals_result["testing"][metric_name],
            )
        )

        self._cur_batch += 1

    def save_diagnostics(self, folder_uri: str, env: AbstractEnv = compat.env):
        """Save train metrics and feature importance for this model."""
        folder_uri = utils.ensure_uri(folder_uri, is_folder=True)

        filesystem = env.get_fs_for_uri(folder_uri)

        LOGGER.info("Saving train metrics for XGB model")
        train_metrics_uri = folder_uri.file("train_metrics.csv")
        with filesystem.open(train_metrics_uri, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=("training", "testing", "batch"))
            writer.writeheader()
            writer.writerows(self._evals_result)

        feature_scores = self.booster.get_score(importance_type="gain")
        LOGGER.debug(
            "XGB raw feature scores (gain)", extra={"data": feature_scores}
        )
        total_score = sum(
            [feature_scores.get(f, 0.0) for f in self.booster.feature_names]
        )
        feature_importances_list = []
        for feature_name in self.booster.feature_names:
            feature_score = feature_scores.get(feature_name, 0.0)
            if feature_score == 0:
                feature_importances_list.append((feature_name, 0.0))
            else:
                feature_importances_list.append(
                    (feature_name, feature_score / total_score)
                )
        feature_importances = sorted(feature_importances_list, key=lambda tup: tup[1])
        feature_importances = {
            feature: str(importance) for feature, importance in feature_importances
        }

        LOGGER.info("Saving feature importances for XGB model")
        feature_importance_uri = folder_uri.file("feature_importance.json")
        env.write_jsonish(feature_importance_uri, feature_importances)

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        categorical_cols = utils.get_categorical_cols(X)
        if categorical_cols:
            LOGGER.debug(
                "Casting %s categorical columns to their subtypes",
                len(categorical_cols),
            )
            X = X.astype(
                {col: X.dtypes[col].categories.dtype for col in categorical_cols}
            )
        data = xgb.DMatrix(X, missing=self.parameters.get("missing"))
        proba: np.ndarray = self.booster.predict(
            data,
            ntree_limit=getattr(self.booster, "best_ntree_limit", 0),
        )
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
