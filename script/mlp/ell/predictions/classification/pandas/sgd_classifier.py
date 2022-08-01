import inspect
import logging
from typing import Optional

import pandas as pd
from sklearn.calibration import CalibratedClassifierCV
from sklearn.linear_model import SGDClassifier as SklearnSGDClassifier

from .pandas_classifier_abc import AbstractPandasClassifier
from ... import utils

LOGGER = logging.getLogger(__name__)


class SGDClassifier(AbstractPandasClassifier):
    """Stochastic-Gradient-Descent-trained classifier.

    This classifier is always calibrated, regardless of the internal
    model / loss function.

    Key parameters and documentation:
    https://scikit-learn.org/stable/modules/generated/sklearn.linear_model.SGDClassifier.html
    """

    WARM_START = False
    DEFAULT_PARAMETERS = dict(
        random_state=42,
    )
    model: CalibratedClassifierCV

    def __init__(self, config: Optional[dict] = None) -> None:
        super().__init__(config)
        self.reset()

    def reset(self):
        LOGGER.info("Initialising model with params", extra={"data": self.parameters})

        params = self.parameters.copy()
        random_state = params.pop("random_state", params.pop("seed", None))
        calibrator_params = utils.trim_params(
            params,
            accepted_params=inspect.signature(CalibratedClassifierCV).parameters,
            warn_for_ignored=False,
        )
        params = utils.trim_params(
            params, accepted_params=inspect.signature(SklearnSGDClassifier).parameters
        )
        self.model = CalibratedClassifierCV(
            SklearnSGDClassifier(random_state=random_state, **params),
            **calibrator_params,
        )

    def _fit(self, X: pd.DataFrame, y: pd.Series) -> None:
        self.model.fit(X, y)

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        proba = self.model.predict_proba(X)
        proba_df = pd.DataFrame(proba, columns=self.model.classes_, index=X.index)
        return proba_df
