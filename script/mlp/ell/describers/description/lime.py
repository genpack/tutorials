"""
An describer model that creates a local linear surrogate model to approximate the predictions of the global
model in an interpretable way
"""

import logging
import re

import lime
import lime.lime_tabular
import sklearn

from ell.describers import utils
from .describer_abc import AbstractDescriber

LOGGER = logging.getLogger(__name__)


class LimeDescriber(AbstractDescriber, aliases=["lime"]):
    def get_categoricals(self, X):
        """
        Lime doesn't handle it well if we pass in dummified categorical variables
        because it needs to perturb categorical and numerical variables differently
        """
        categorical_positions = []
        for feature in self.categoricals:
            categorical_positions.append(X.columns.get_loc(feature))

        categorical_names = {}
        for feature in self.categoricals:
            le = sklearn.preprocessing.LabelEncoder()
            le.fit(X[feature])
            categorical_names[X.columns.get_loc(feature)] = {
                x: x for x in list(le.classes_.astype(int))
            }

        return categorical_positions, categorical_names

    def describe_raw(
        self,
        row,
        verbose=False,
        discretizer="quartile",
        discretize_continuous=True,
        kernel_width=3,
        min_parsimony=0.9,
        features=None,
    ):
        """
        Get raw lime explanation

        :param row:
        :param features:
        :param verbose:
        :param discretizer: 'quartile' or 'decile'
        :param discretize_continuous: boolean, whether we discretize continuous features and turn them into categoricals
        :param kernel_width: Size of the local area that LIME generates
        :param min_parsimony:
        :returns: LIME explanation
        """
        if features is None:
            features = []
        row = utils.filter(row)

        categorical_positions, categorical_names = self.get_categoricals(self.X)
        full_features = self.X.shape[1]

        if min_parsimony < 1:
            num_features = max(int(full_features * (1 - min_parsimony)), 1)
        else:
            num_features = min_parsimony

        describer = lime.lime_tabular.LimeTabularDescriber(
            self.X.values,
            feature_names=list(self.X.columns),
            discretize_continuous=discretize_continuous,
            kernel_width=kernel_width,
            categorical_features=categorical_positions,
            categorical_names=categorical_names,
            discretizer=discretizer,
        )

        explanation = describer.describe_instance(
            row.values[0], self.predict_probabilities_fn
        ).as_list()

        explanation = dict(explanation)

        explanation = {k: v for k, v in explanation.items() if k in features}
        explanation = tuple(explanation)
        explanation = sorted(explanation, key=lambda x: abs(x[1]), reverse=True)
        if len(explanation) > num_features:
            explanation = explanation[:num_features]

        explanation = dict(explanation)

        return explanation

    def describe(
        self,
        row,
        verbose=False,
        discretizer="quartile",
        discretize_continuous=True,
        kernel_width=3,
        min_parsimony=0.9,
        **params,
    ):

        """
        Get nicely formatted LIME explanation

        :param row:
        :param verbose:
        :param discretizer: 'quartile' or 'decile'
        :param discretize_continuous: boolean, whether we discretize continuous features and turn them into categoricals
        :param kernel_width: Size of the local area that LIME generates
        :param min_parsimony:
        :returns: [prediction, explanation]
        """

        real_features = self.X.columns

        data = self.describe_raw(
            row,
            verbose=verbose,
            discretizer=discretizer,
            min_parsimony=min_parsimony,
            discretize_continuous=discretize_continuous,
            kernel_width=kernel_width,
        )

        clean_data = {}

        for entry in data:
            # Clean the entry
            # match it to a name in real_features
            # make a new entry in the dict with the same value as before
            # but key the matched name
            # delete the old entry
            for feature in real_features:
                match = re.findall(str(feature), entry)
                if len(match) > 0:
                    clean_name = match[0]
                    if len(match) > 1:
                        print(
                            "Error, string matching returned multiple results. Format categorical strings better"
                        )

                    clean_data[clean_name] = data[entry]

        prediction = self.predict_categories_fn(row)

        return [prediction, clean_data]

    @staticmethod
    def interpret_string_explanation(explanation, features, categoricals):
        """
        Explanation currently looks like this:
           ['index <= 2000.75',
            'currentInterestRate <= 6.59',
            '651.00 < currentCreditScore <= 717.00',
            '5.75 < RBArateAtOrigination <= 8.00',
            'originalLTV <= 18.31',
            'inbound_emails > 2.00']

        We need it to be a dict that looks like this:
               {'index': {'upper': 2000.72',
                          'lower': None',
                          ....
                          ....
                          and so on

        So we need to interpret the string.
        Warning: We assume that each feature only occurs once. If your
        describer is not well behaved, will cause undefined behaviour

        :param explanation: Explanation of the format above
        :param features: List of features that could possibly appear in the explanation
        :param categoricals: List of features in the above list which are categorical features
        :returns: A box dict
        """

        box = {}
        for feature in features:
            matching_string = str("(^" + feature + "[ <>=])|(< " + feature + " <=)")
            for row in explanation:
                """
                This condition is a little weird, for good reason
                The word age appears in "average". So if we look for when
                "age" is in features, it will appear twice.

                If we get an upper and lower, we always have " feature " with
                the spaces. But if we only have an upper or a lower, we don't
                have the beginning space.

                But if we only look at the end space, then age is confused with
                average. So we need to  check if the string starts with out feature,
                and then contains our feature at the end with a comparison symbol.

                Got a better idea? Implement it please.

                We also have a problem with rounding. 1.149 will get rounded
                to 1.15, but then if we use the 1.15 to filter it will cut out
                the 1.49. So we will fudge the edges a bit. And then round
                for categorical variables.
                """
                compiled = re.compile(matching_string)
                if bool(re.search(compiled, row)):
                    if feature not in box.keys():
                        # Note that sometimes we have two conditions, an upper one and a lower one. So allow repeating
                        box[feature] = {"lower": None, "upper": None}
                        old_upper = None
                        old_lower = None
                    else:
                        old_upper = box[feature]["upper"]
                        old_lower = box[feature]["lower"]

                    extracted = [float(s) for s in re.findall(r"-?\d+\.?\d*", row)]

                    if "<=" in row and "< " in row:
                        box[feature]["lower"] = extracted[0] - 0.01
                        box[feature]["upper"] = extracted[-1] + 0.01
                        # We have an upper and a lower
                    elif "<=" in row:
                        # Note that if we have that the variable exactly equals a value,
                        # we put it on the upper bound
                        box[feature]["upper"] = extracted[-1] + 0.01
                        # We only have an upper
                    elif ">" in row:
                        box[feature]["lower"] = extracted[-1] - 0.01

                        # We only have a lower, and it's at the end
                    elif "=" in row:
                        # This is when we have precise equality
                        # Only happens with categorical variables, don't need
                        # to fudge
                        box[feature]["lower"] = extracted[-1] - 1
                        box[feature]["upper"] = extracted[-1]

                    if feature in categoricals:
                        if box[feature]["lower"] is not None:
                            box[feature]["lower"] = float(round(box[feature]["lower"]))

                        if box[feature]["upper"] is not None:
                            box[feature]["upper"] = float(round(box[feature]["upper"]))

                    # If we have duplicate conditions, we want to take the most narrow one
                    if box[feature]["upper"] is not None or old_upper is not None:
                        box[feature]["upper"] = min(
                            [
                                a
                                for a in [box[feature]["upper"], old_upper]
                                if a is not None
                            ]
                        )
                    if box[feature]["lower"] is not None or old_lower is not None:
                        box[feature]["lower"] = max(
                            [
                                a
                                for a in [box[feature]["lower"], old_lower]
                                if a is not None
                            ]
                        )

        return box

    def get_box(self, row, exclude_categoricals=None, features=None, **params):

        features = features or self.X.columns
        explanation = self.describe_raw(row, **params)
        # features = self.X.columns

        box = self.interpret_string_explanation(
            explanation, features, self.categoricals
        )

        for feature in box.keys():
            box[feature]["actual"] = float(row[feature].values[0])

        return box
