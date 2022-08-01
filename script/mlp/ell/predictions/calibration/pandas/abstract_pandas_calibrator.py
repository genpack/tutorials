import abc

import pandas as pd

from ..calibrator_abc import AbstractCalibrator


class PandasAbstractCalibrator(AbstractCalibrator, abc.ABC):
    @abc.abstractmethod
    def fit(self, probas: pd.DataFrame) -> None:
        raise NotImplementedError

    @abc.abstractmethod
    def transform(self, probas: pd.DataFrame) -> pd.DataFrame:
        raise NotImplementedError
