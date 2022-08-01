import logging
from typing import List

import pandas as pd
from scipy import stats

from .pandas_ensembler_abc import AbstractPandasAverager

LOGGER = logging.getLogger(__name__)


class AveragingEnsembler(AbstractPandasAverager):
    def _coalesce_probas(self, probas_list: List[pd.DataFrame]) -> pd.DataFrame:
        if not probas_list:
            raise ValueError("probas_list is empty")

        if len(frozenset(proba_df.shape for proba_df in probas_list)) != 1:
            raise ValueError(
                "Can't average probabilities across DataFrames with different shapes"
            )

        new_probas_list = []
        for i, df in enumerate(probas_list):

            # Sometimes one XGB will scale its predictions a bit differently to another,
            # even if the orders are relatively similar. So we normalize them by spacing
            # them all out between 0 and 1
            if self.parameters.get("normalize", True):
                if df.shape[1] > 2:
                    raise ValueError(
                        "Cannot normalize probabilities for multi-class prediction"
                    )
                pos_probs = df.iloc[:, 1]
                pos_probs = stats.rankdata(pos_probs) / len(pos_probs)
                df = df.copy()
                df.iloc[:, 1] = pos_probs
                df.iloc[:, 0] = 1 - pos_probs

            df = df.set_axis(
                pd.MultiIndex.from_arrays(
                    [[i] * df.shape[1], list(df.columns)], names=("index", "class")
                ),
                axis="columns",
            )
            new_probas_list.append(df)

        proba_df = pd.concat(new_probas_list, axis="columns").mean(
            axis="columns", level="class"
        )

        return proba_df
