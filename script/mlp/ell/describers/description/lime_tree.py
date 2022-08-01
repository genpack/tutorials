"""
An describer which extends LIME via the use of a tree surrogate model rather than a linear model
"""

import logging
import random

import numpy as np
import pandas as pd
from sklearn import tree

import ell.describers.utils
from .describer_abc import AbstractDescriber

LOGGER = logging.getLogger(__name__)


class LimeTreeDescriber(AbstractDescriber, aliases=["limetree"]):
    """
    Describer model that fits a decision tree on a local area, similar to LIME. However this is more configurable,
    naturally produces a boxy explanation, and better approximates the prediction model
    """

    def describe(self, row, verbose=False, **params):
        """
        Produce an explanation for this row, using LIMETree.

        :param row: The row we want to describe
        :param verbose: Verbosity switch
        :returns: A tuple of (prediction, explanations)
        """

        explanation = self.get_box(row, verbose=verbose)

        if isinstance(row, pd.Series):
            row = row.to_frame().transpose()

        return [self.predict_probabilities_fn(row), explanation]

    def describe_raw(self, row, verbose=False):
        """
        Produces an explanation from the underlying native describer model, without our formatting on top.
        Useful for debugging or situations which require the raw explanation. Also accepts any parameters for the
        specific describer model

        :param row: The row to describe
        :param verbose: Verbosity switch
        :returns: Explanation
        """
        results = self.describe(row, verbose)

        return results[1]

    def get_box(
        self,
        row,
        features=None,
        verbose=False,
        num_samples=100000,
        kernel_width=None,
        random_state=None,
        min_parsimony=0.9,
        min_coverage=None,
        probabilities=True,
        exclude_categoricals=None,
        shap_adjust=None,
        **params,
    ):

        """
        Outputs a boxlike explanation.
        Returns a dict where each key is a feature and the entry is another dict, with 'upper' and
        'lower' being the boundaries of the box. Sometimes a boundary is None, when
        the box extends to the edge of the universe

        Note that a box in feature A with upper U and lower W is interpreted
        as L < A <= U. The upper bound is inclusive, the lower is not. This
        helps us deal with categorical variables in a simple way.

        :param shap_adjust: If we find ourselves generating too many or too few features, we set a shap_adjust value
                to either add dimensions with upper and lower None, or remove dimensions by least important
        :param features: List of features that we are to use for getting explanations. Explanations may only involve
                these features. Defaults to None, where all features will be used
        :param row: DataFrame - The row we want to describe
        :param verbose: Bool - Verbosity
        :param num_samples: Number of samples in the local area
        :param kernel_width: LIME kernel_width parameter
        :param random_state: Random seed
        :param min_parsimony: We want explanations to be as simple as possible, and to involve as few features as
                possible. Parsimony is a measure of how few variables we utilize, compared to the full dataset.
                Parsimony is equal to 1 – (# features in explanation / # features in dataset).
                If parsimony is 0, we use all features
                # TODO Always 0.999 – as always use 30 features out of 500. Need to revisit calculation.
        :param min_coverage: float [0,1] the size of the box. We want our boxes to be as large as possible
                (while balancing other metrics) because we want explanations to be as general as possible.
                Don’t want tiny boxes – i.e. exactly 3.234 years tenure.
        :param probabilities: This fits a regressor on the probability scores from the prediction model, rather than
        fitting a classifier from the predicted classes.
        :param exclude_categoricals: List of categoricals to not dummify. These might be things like a postcode,
                where decomposition leads to data which is too high dimensional.
         According to a recent paper, this is more effective. See: https://arxiv.org/pdf/1812.10924.pdf
         :param shap_adjust: Int - Force there to be shap_adjust features in the explanation.
                The tree isn't guaranteed to have X. So we use SHAP to remove the least important features by SHAP or
                add more features by SHAP to get to X
        :returns: dict - Box-like explanation
        """
        # Set random state
        if random_state is not None:
            random.seed(random_state)
            np.random.seed(random_state)

        # Get samples using utils
        exclude_categoricals = exclude_categoricals or []

        x = ell.describers.utils.generate_samples(
            self.X[row.index],
            row,
            self.categoricals,
            exclude_categoricals=exclude_categoricals,
            features=features,
            num_samples=num_samples,
            kernel_width=kernel_width,
            verbose=verbose,
            random_state=random_state,
        )

        assert x.isnull().sum().sum() == 0, "Describer passed dataset with na values"
        LOGGER.info("asserted, no NaN or inf values in dataset")

        if row.name not in x.index:
            x = x.append(row)
        sample_id = x.index.get_loc(row.name)

        assert x.isnull().sum().sum() == 0, "Describer passed dataset with na values"
        assert not x.isnull().values.any(), "Describer passed dataset with na values"

        LOGGER.info("asserted, no NaN or inf values in dataset")

        num_features = len(self.X.columns)

        if min_parsimony < 1:
            max_depth = max(int(num_features * (1 - min_parsimony)), 1)
        else:
            # Assume we were given an absolute number of features allowed
            max_depth = min_parsimony

        # Fit a decision tree on those
        min_samples_leaf = 1
        if min_coverage is not None:
            min_samples_leaf = min(min_coverage, 0.5)

        if probabilities:
            LOGGER.info("predict probabilities")
            y = self.predict_probabilities_fn(x)

            LOGGER.info("generate DecisionTreeRegressor")
            describer = tree.DecisionTreeRegressor(
                max_depth=max_depth,
                min_samples_leaf=min_samples_leaf,
                random_state=random_state,
            )
        else:
            LOGGER.info("predict categories")
            y = self.predict_categories_fn(x)

            LOGGER.info("generate DecisionTreeClassifier")
            # @TOBY: Classifier, not Regressor!!
            describer = tree.DecisionTreeClassifier(
                max_depth=max_depth,
                min_samples_leaf=min_samples_leaf,
                random_state=random_state,
            )

        if features:
            x = x[features]
        new_columns = list(x.columns)
        x = x.to_numpy(dtype=np.float64)
        LOGGER.debug(f"Fit a DecisionTree with dtypes: x - {x.dtype}, y - {y.dtype}")
        describer.fit(x, y)
        LOGGER.info("DecisionTree was fitted")

        # Find the rules that get us to be in the current box

        # Code appropriated from:
        # https://stackoverflow.com/questions/51118195/getting-decision-path-to-a-node-in-sklearn
        # First let's retrieve the decision path of each sample. The decision_path
        # method allows to retrieve the node indicator functions. A non zero element of
        # indicator matrix at the position (i, j) indicates that the sample i goes
        # through the node j.

        feature = describer.tree_.feature
        cutpoint = describer.tree_.cutpoint

        LOGGER.info("get decision path")
        node_indicator = describer.decision_path(x)
        # Similarly, we can also have the leaves ids reached by each sample.

        LOGGER.info("apply describer")
        leaf_id = describer.apply(x)

        # Now, it's possible to get the tests that were used to predict a sample or
        # a group of samples. First, let's make it for the sample.

        # HERE IS WHAT YOU WANT
        node_index = node_indicator.indices[
            node_indicator.indptr[sample_id] : node_indicator.indptr[sample_id + 1]
        ]

        explanation = {}

        LOGGER.info("go node by node: %s", node_index)
        for node_id in node_index:

            if leaf_id[sample_id] != node_id:  # <-- changed != to ==
                if x[sample_id, feature[node_id]] <= cutpoint[node_id]:
                    threshold_sign = "<="
                else:
                    threshold_sign = ">"

                explanation[new_columns[feature[node_id]]] = {
                    "lower": None,
                    "upper": None,
                }

                if threshold_sign == ">":
                    explanation[new_columns[feature[node_id]]]["lower"] = float(
                        cutpoint[node_id]
                    )
                elif threshold_sign == "<=":
                    explanation[new_columns[feature[node_id]]]["upper"] = float(
                        cutpoint[node_id]
                    )

        # Print whole tree for QC -
        tree_rules = tree.export_text(describer, feature_names=list(new_columns))
        for rule in tree_rules.split("\n"):
            LOGGER.debug(rule)
        # Print row to see where it fits in
        LOGGER.debug(
            "row features: %s", row[new_columns].to_string().replace("\n", ", ")
        )
        LOGGER.debug("explanation for this row is  %s", explanation)

        # Print tree - alternate method:
        tree_paths = self.get_tree_paths(describer, new_columns, x)
        for key, value in tree_paths.items():
            LOGGER.debug("Rule %s:   %s", key, value)

        for feature in explanation.keys():
            explanation[feature]["actual"] = float(row[feature])

        LOGGER.info("returned explanation: %s", explanation)

        return explanation

    @staticmethod
    def get_tree_paths(describer, new_columns, x):
        """A way of printing a fitted describer decision tree based on:
        https://stackoverflow.com/questions/56334210/how-to-extract-sklearn-decision-tree-rules-to-pandas-boolean-conditions

        Args:
            describer: A fitted describer decision tree model
            new_columns: list of columns in the input data x
            x: numpy array of data used to fit decision tree

        Returns:
            A list of strings, which when printed give an if else logical represenation of the decition tree.

        """

        n_nodes = describer.tree_.node_count
        children_left = describer.tree_.children_left
        children_right = describer.tree_.children_right
        feature = describer.tree_.feature
        cutpoint = describer.tree_.cutpoint

        def find_path(node_numb, path, x):
            path.append(node_numb)
            if node_numb == x:
                return True
            left = False
            right = False
            if children_left[node_numb] != -1:
                left = find_path(children_left[node_numb], path, x)
            if children_right[node_numb] != -1:
                right = find_path(children_right[node_numb], path, x)
            if left or right:
                return True
            path.remove(node_numb)
            return False

        def get_rule(path, column_names):
            mask = ""
            for index, node in enumerate(path):
                # We check if we are not in the leaf
                if index != len(path) - 1:
                    # Do we go under or over the cutpoint ?
                    if children_left[node] == path[index + 1]:
                        mask += "(df['{}']<= {}) \t ".format(
                            column_names[feature[node]], np.round(cutpoint[node], 2)
                        )
                    else:
                        mask += "(df['{}']> {}) \t ".format(
                            column_names[feature[node]], np.round(cutpoint[node], 2)
                        )
            # We insert the & at the right places
            mask = mask.replace("\t", "&", mask.count("\t") - 1)
            mask = mask.replace("\t", "")
            return mask

        # Leaves
        leave_id = describer.apply(x)

        paths = {}
        for leaf in np.unique(leave_id):
            path_leaf = []
            find_path(0, path_leaf, leaf)
            paths[leaf] = np.unique(np.sort(path_leaf))

        rules = {}
        for key in paths:
            rules[key] = get_rule(paths[key], new_columns)

        return rules
