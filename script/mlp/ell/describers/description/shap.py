"""
A wrapper for the shap describer, which provides an explanation by computing shapley values which can be
interpreted as a special kind of feature importance that is additive. We also turn it into a box explanation.
"""

import logging
import operator

import numpy as np
import pandas as pd

try:
    import shap
except ModuleNotFoundError:
    shap = None

from .describer_abc import AbstractDescriber

LOGGER = logging.getLogger(__name__)


class ShapDescriber(AbstractDescriber, aliases=["shap"]):
    # TODO: Write a feature scoring method which gets aggregates

    def __init__(self, *args, **kwargs) -> None:
        if shap is None:
            raise RuntimeError("Shap is not installed!")
        super().__init__(*args, **kwargs)

    def __init__(self, *args, **kwargs):
        if shap is None:
            raise RuntimeError("Shap is not installed!")
        super().__init__(*args, **kwargs)

    def describe(self, row, verbose=False, kmeans=30, nonzero=True, **params):
        """
        Shap feature importance explanation

        :param row:
        :param verbose:
        :param kmeans: Shap kmeans parameter. Increasing leads to better explanations and longer running times
        :param nonzero: When we produce the final explanation dict, do we only include features with non-zero importance? Boolean
        :returns: [prediction, explanation]
        """
        if isinstance(row, pd.Series):
            row = row.to_frame().transpose()

        data = shap.kmeans(self.X, kmeans)

        describer = shap.KernelDescriber(self.predict_probabilities_fn, data)

        prediction = self.predict_probabilities_fn(row)
        category = self.predict_categories_fn(row)

        # describer.shap_values gives [explanation of why case 0, explanation of why case 1]
        # But we only want the explanation for whichever case we predict happens
        # So we get the prediction
        shap_explanation = describer.shap_values(row.values[0], verbose=False)
        shap_explanation = shap_explanation[int(category[0])]

        explanation = {
            k: v
            for k, v in zip(self.X.columns, shap_explanation)
            if v != 0 or nonzero is False
        }

        return [prediction, explanation]

    def describe_raw(self, row, verbose, kmeans=30):
        """
        Raw shap explanation

        :param kmeans: Shap kmeans parameter. Increasing leads to better explanations and longer running times
        :param row:
        :param verbose:
        :return:
        """
        if isinstance(row, pd.Series):
            row = row.to_frame().transpose()
        results = self.describe(row, verbose, nonzero=False, kmeans=kmeans)

        return results[1]

    def get_sensitivity(self, row, subset, kmeans=30):
        """
        Return the sensitivity only for the features that we are interested in

        :param kmeans: Shap kmeans parameter. Increasing leads to better explanations and longer running times
        :param row:
        :param subset: The subset of features that we are interested in
        :return:
        """
        if isinstance(row, pd.Series):
            row = row.to_frame().transpose()
        _, explanation = self.describe(row, nonzero=False, kmeans=kmeans)

        return {k: explanation[k] for k in subset}

    def get_box(
        self, row, verbose=False, min_parsimony=0, kmeans=30, features=None, **params
    ):
        """
        We get a box by taking the most important features according to shap, and adding the discretizer boundaries
        as the upper and lower of a box, until we've got enough features

        :param features: List of features that are allowed to appear in the explanation
        :param row: One row dataframe to describe
        :param verbose: Verbosity switch
        :param min_parsimony: The minimum parsimony required. If an integer, the max number of features allowed
        :param kmeans: Shap kmeans parameter. Increasing leads to better explanations and longer running times
        :return:
        """
        if isinstance(row, pd.Series):
            row = row.to_frame().transpose()

        if features:
            explanation = self.get_sensitivity(row, features, kmeans=kmeans)
        else:
            _, explanation = self.describe(row, verbose, kmeans, nonzero=False)
        row = row.iloc[0]
        box = {}

        if min_parsimony < 1:
            max_features = max(int(self.X.shape[1] * (1 - min_parsimony)), 1)
        else:
            max_features = min_parsimony

        while len(box.keys()) < max_features:
            # Find the next highest feature
            feature = max(explanation.items(), key=operator.itemgetter(1))[0]

            # Find the quartile boundaries
            quartiles = np.percentile(self.X[feature], [25, 50, 75])

            # Find the quartile boundaries that include the row
            upper = None
            lower = None
            if row[feature] <= quartiles[0]:
                upper = quartiles[0]
            elif quartiles[0] < row[feature] <= quartiles[1]:
                upper = quartiles[1]
                lower = quartiles[0]
            elif quartiles[1] < row[feature] <= quartiles[2]:
                upper = quartiles[2]
                lower = quartiles[1]
            if row[feature] > quartiles[2]:
                lower = quartiles[2]

            # Add the box level
            actual = row[feature]
            box[feature] = {"upper": upper, "lower": lower, "actual": actual}

            # Delete the reason from the explanation
            del explanation[feature]

        return box
