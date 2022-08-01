import logging

import numpy as np
import pandas as pd

LOGGER = logging.getLogger(__name__)

__all__ = ["ReadFromPersisted"]


class ReadFromPersisted:
    """
    Class used to store one instance of all the data computed beforehand.
    Its methods are defined to get data that may be need during computation in an efficient manner.
    """

    def __init__(self, prediction_df):
        self.prediction_df = prediction_df

    def get_probabilities(self, X: pd.DataFrame) -> np.ndarray:
        """
        Function that returns the predicted probabilities for the index required as input
        The format of the input and output matches the format of the predict_category function in AbstractClassificationModel
        @param X: dataframe containing the IDs to get the predictions from.
        @return probs: 2d array containing the probabilities for the required index.
        """
        if not isinstance(X.index, pd.MultiIndex):
            X = X.set_index(["caseID", "eventTime"])
        _probs = self.prediction_df.loc[X.index]
        _probs = _probs.probability.to_numpy(dtype="float64")
        probs = np.zeros((len(_probs), 2))
        probs[:, 0] = 1 - _probs
        probs[:, 1] = _probs
        return probs

    def get_categories(self, X: pd.DataFrame) -> np.array:
        """
        Function that returns the predicted categories for the index of the dataframe specified as input.
        The format of the input and output matches the format of the predict_category function in AbstractClassificationModel
        @param X: dataframe containing the IDs to get the predictions from.
        @return cats: array containing the categories for the required index.
        """
        if not isinstance(X.index, pd.MultiIndex):
            X = X.set_index(["caseID", "eventTime"])
        cats = self.prediction_df.loc[X.index].category.to_numpy(dtype="int32")
        return cats
