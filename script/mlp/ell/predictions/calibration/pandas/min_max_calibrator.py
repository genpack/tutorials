from typing import Optional

import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler

from .pandas_calibrator_abc import PandasAbstractCalibrator


class MinMaxCalibrator(PandasAbstractCalibrator):
    def __init__(self, config: Optional[dict] = None) -> None:
        super().__init__(config)
        self.scaler = MinMaxScaler(feature_range=(0, 1))
        self.isfit = False

    @staticmethod
    def _check_input(probas):
        if probas.shape[1] != 2:
            raise ValueError("MinMaxCalibrator does not support multiclass.")
        if probas.min().min() < 0 or probas.max().max() > 1:
            raise ValueError(
                "Probabilities should takes values between 0 and 1 to be calibrated."
            )

    def fit(self, probas: pd.DataFrame) -> None:
        self._check_input(probas)
        class0_probas = probas.iloc[:, 0]
        self.scaler.fit(class0_probas.to_numpy().reshape(-1, 1))
        self.isfit = True

    def transform(self, probas: pd.DataFrame) -> pd.DataFrame:
        self._check_input(probas)
        if not self.isfit:
            raise RuntimeError(
                "The calibrator needs to be fitted before transformation."
            )
        class0_probas = probas.iloc[:, 0]
        class0_probas_scaled = self.scaler.transform(
            class0_probas.to_numpy().reshape(-1, 1)
        ).clip(0, 1)
        return pd.DataFrame(
            np.concatenate(
                [
                    class0_probas_scaled,
                    1 - class0_probas_scaled,
                ],
                axis=1,
            ),
            index=probas.index,
            columns=probas.columns,
        )
