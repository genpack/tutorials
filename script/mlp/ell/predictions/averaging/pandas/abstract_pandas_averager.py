import abc
from typing import List, TYPE_CHECKING

import pandas as pd

from ell.predictions.classification import AbstractPandasClassifier
from ..ensembler_abc import AbstractAverager

if TYPE_CHECKING:
    from ell.predictions import Model


class AbstractPandasAverager(AbstractAverager, AbstractPandasClassifier, abc.ABC):
    models: List["Model"]

    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        probas_list = []
        for model in self.models:
            if model.features:
                probas = model.predict(X[sorted(model.features)])[0]
            else:
                probas = model.predict(X)[0]
            probas_list.append(probas)

        return self._coalesce_probas(probas_list)

    @abc.abstractmethod
    def _coalesce_probas(self, probas_list: List[pd.DataFrame]) -> pd.DataFrame:
        raise NotImplementedError

    def _fit(self, X, y):
        # Because the ensembler doesn't actually fit to data itself
        # (yet), this method does nothing.
        pass
