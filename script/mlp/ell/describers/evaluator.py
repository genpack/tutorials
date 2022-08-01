"""
Contains code for calculating all the metrics on the weighted actual
dataset, rather than the local area implementation.

The weighted actual dataset is calculated through scaling, and then an
l2 distance from our row.
"""
import logging

import numpy as np
import pandas as pd
from scipy import stats
from scipy.sparse import issparse
from sklearn.metrics import pairwise
from sklearn.preprocessing import MinMaxScaler
from sklearn.utils import validation

from ell.predictions import utils as predutils
from ell.predictions.transformation import Dummifier

LOGGER = logging.getLogger(__name__)


class ExplanationEvaluator:
    def __init__(
        self,
        dataset,
        predict_or_get_probabilities,
        predict_or_get_categories,
        encodings=None,
        exclude_categoricals=None,
        features=None,
    ):
        """
        Class for evaluating explanations

        :param exclude_categoricals: List of features to not dummify, such as postcode, as decomposing would cause dimensionality to be too high
        :param dataset: Dataframe to use to evaluate. Should be the full dataset, or large random sample
        :param predict_or_get_probabilities: function that computes and return the probabilites for the specified dataset
        when they can't be directly read from the inference prediction results.
        :param predict_or_get_categories: function that computes and return the categories for the specified dataset
        when they can't be directly read from the inference prediction results.
        :param encodings: Categorical_encodings dict associated with the dataset
        :param exclude_categoricals: List of categoricals to not dummify. These might be things like a postcode,
                where decomposition leads to data which is too high dimensional.
        :param features: List of features that we are to use for getting explanations. Explanations may only involve
                these features. Defaults to None, where all features will be used
        """

        LOGGER.debug("ExplanationEvaluator __init__")

        if features:
            self.features = features
        else:
            self.features = list(dataset.columns)
            LOGGER.debug(
                "evaluator was not passed features, setting to be dataset.columns {}".format(
                    self.features
                )
            )

        encodings = encodings or {}
        exclude_categoricals = exclude_categoricals or []

        self.original_features = dataset.columns
        self.categoricals = [
            _ for _ in list(set(list(encodings.keys()))) if _ in self.features
        ]
        self.encodings = encodings
        self.feature_scaler = MinMaxScaler()
        self.distance_scaler = MinMaxScaler()
        self.predict_or_get_probabilities = predict_or_get_probabilities
        self.predict_or_get_categories = predict_or_get_categories

        self.dummifier = Dummifier(
            config=dict(
                input=dict(
                    include=dict(categoricals=True), exclude=exclude_categoricals
                )
            )
        )

        self.weighted_df = None
        LOGGER.info("weighted df set to None")

        self.row = None
        self.target = None
        self.prediction = None

        assert dataset.isna().sum().sum() == 0, "Describer passed na value"
        LOGGER.info("dataset has no NaN or inf")

        mean = dataset[self.features].mean()
        std = dataset[self.features].std()
        max_std = 2

        lower = mean - max_std * std
        upper = mean + max_std * std

        # clip dataset to lower and upper bounds
        self.df_out_handled = dataset[self.features].clip(
            lower=lower, upper=upper, axis=1
        )

        # keep original categorical features
        self.df_out_handled[self.categoricals] = dataset[self.categoricals]
        LOGGER.info("dataset outliers removed.")

        self.df = dataset

    def calculate_weights(self, row: pd.DataFrame, features):
        """
        Calculates the weight of each point in the dataset, by finding the l2 distance from the row we are describing
        after decomposing, removing outliers and scaling

        :param row: Dataframe with only one row: the row we are describing
        :param features: The subset of features to use for describing
        :returns: A df with two new columns: __weight__ and __distance__
        """
        LOGGER.debug("start calculate weights")
        LOGGER.debug("copied df")

        df = self.df_out_handled[features]
        row = row[features]

        # Dummify categoricals
        numerical_cols = predutils.get_numerical_cols(df)
        # Drop original categorical columns and join the dummified columns
        df = df[numerical_cols].join(self.dummifier.fit_transform(df))
        row = row[numerical_cols].join(self.dummifier.transform(row))

        LOGGER.debug(
            "df columns after joining with dummified", extra={"data": df.columns}
        )

        df = pd.DataFrame(
            self.feature_scaler.fit_transform(df),
            columns=df.columns,
            index=df.index,
        )
        row = pd.DataFrame(
            self.feature_scaler.transform(row),
            columns=row.columns,
            index=row.index,
        )
        LOGGER.debug("features scaled")

        differences = row.iloc[0] - df
        LOGGER.debug("differences calculated")

        dist_norms = np.linalg.norm(differences, ord=2, axis=1).reshape(-1, 1)
        LOGGER.debug("distance norms calculated")

        # Scale the l2 distance
        dist_norms = self.distance_scaler.fit_transform(dist_norms)
        LOGGER.debug("distance norms scaled")
        weights = np.square(1 - dist_norms)
        LOGGER.debug("weights calculated")

        # Return weights and distance norms as extra columns on the
        # original dataframe.
        df = self.df.assign(__weight__=weights, __distance__=dist_norms)
        return df

    def inside_box(self, box):
        """
        For many metrics, we want to consider only the points that are inside our box
        So this returns a subset of dataset that is inside the box

        :param box: The box we want to find the inside of
        :returns: A dataframe containing only rows of the dataset that are inside the box
        """

        dataset = self.weighted_df

        list_features = [e for e in box.keys() if not e.startswith("tree_rules")]
        for feature in list_features:
            if box[feature]["lower"] is not None:
                dataset = dataset[dataset[feature] > box[feature]["lower"]]
            if box[feature]["upper"] is not None:
                dataset = dataset[dataset[feature] <= box[feature]["upper"]]

            # assert (box[feature]['upper'] != box[feature]['lower']), "Box upper, lower for " + str(
            #     feature) + " are equal" # I think sometimes we want to allow this

        if len(dataset) == 0:
            LOGGER.warning("Nothing inside the box")

        return dataset

    def scores(self, box, row, features=None):
        """
        Calculate all scores

        :param box: Box dict
        :param row: Row dataframe
        :param features: List of features to use for explanations
        :returns: A dict with each score
        """
        if isinstance(row, pd.Series):
            row = row.to_frame().transpose()
        LOGGER.info("start scores function")

        self.weighted_df = self.calculate_weights(row, features)
        LOGGER.info("Calculated weighted_Df")

        self.row = row
        self.target = self.predict_or_get_categories(row)[0]
        LOGGER.info("target category predicted")
        self.prediction = self.predict_or_get_probabilities(row)[0][self.target]
        LOGGER.info("row probability predicted")

        in_box = self.inside_box(box)
        LOGGER.info("calculated in_box: %s", in_box)

        out_box = self.weighted_df.loc[self.weighted_df.index.difference(in_box.index)]
        LOGGER.info("calculated out_box: %s", out_box)

        if not in_box.empty:
            in_box["predictions"] = self.predict_or_get_categories(
                in_box[self.original_features]
            )
            in_box["probabilities"] = [
                a[self.target]
                for a in self.predict_or_get_probabilities(
                    in_box[self.original_features]
                )
            ]
        if not out_box.empty:
            out_box["predictions"] = self.predict_or_get_categories(
                out_box[self.original_features]
            )
            out_box["probabilities"] = [
                a[self.target]
                for a in self.predict_or_get_probabilities(
                    out_box[self.original_features]
                )
            ]
        self.weighted_df["probabilities"] = [
            a[self.target]
            for a in self.predict_or_get_probabilities(
                self.weighted_df[self.original_features]
            )
        ]
        LOGGER.info("predicted weighted probabilities")

        scores = {
            "precision": self.precision(box, in_box),
            "npv": self.npv(box, in_box, out_box),
            "power": self.power(box, in_box, out_box),
            "coverage": self.coverage(box, in_box),
            "parsimony": self.parsimony(box),
            "gain": self.gain(box, in_box, out_box),
            "fidelity": self.fidelity(box, in_box, out_box),
        }

        scores = {k: float(v) for k, v in scores.items()}
        LOGGER.info("end scores function", extra={"data": scores})
        return scores

    def precision(self, box, in_box=None):
        """
        Like a classification model (since our explanations basically
        are classification models), precision measures how accurate
        our explanation is. How homogeneous the inside of our box is. What proportion
        of the inside cases are the desired class

        Returns float between 0 and 1, higher is better

        :param box: Box to test
        :param in_box: Optional pre-compute of parts of the dataset inside the box
        :returns: float between 0 and 1
        """
        LOGGER.debug("start precision")

        if in_box is None:
            in_box = self.inside_box(box)
            in_box["predictions"] = self.predict_or_get_categories(
                in_box[self.original_features]
            )

        if in_box.empty:
            LOGGER.warning("Nothing inside box")
            return 0

        predicted_positives = in_box["__weight__"].sum()

        true_positives = in_box[in_box["predictions"] == self.target][
            "__weight__"
        ].sum()

        precision = true_positives / predicted_positives
        LOGGER.debug("precision: %s", precision)
        return precision

    def npv(self, box, in_box=None, out_box=None):
        """
        Negative prediction value is how homogeneous the outside of our box is. We
        want our box to capture the behaviour of our model at a local level, so we
        want the inside to be the desired class and the outside to not be the desired
        class. Think of npv as negative precision.

        Returns float between 0 and 1, higher is better

        :param box: Box to test
        :param in_box: Optional pre-compute of parts of the dataset inside the box
        :returns: float between 0 and 1
        """
        LOGGER.debug("start npv")

        if in_box is None or out_box is None:
            in_box = self.inside_box(box)
            LOGGER.debug("in_box shape: %s", in_box.shape)
            out_box = self.weighted_df[~self.weighted_df.index.isin(in_box.index)]
            LOGGER.debug("out_box shape: %s", out_box.shape)
            out_box_filtered = out_box[self.original_features]
            LOGGER.debug("out_box_filtered shape: %s", out_box_filtered.shape)
            out_box["predictions"] = self.predict_or_get_categories(out_box_filtered)

        if out_box.empty:
            LOGGER.warning("Out-box empty for box {}".format(box))
            return 0

        predicted_negatives = out_box["__weight__"].sum()

        true_negatives = out_box[out_box["predictions"] != self.target][
            "__weight__"
        ].sum()

        npv = true_negatives / predicted_negatives
        LOGGER.debug("npv: %s", npv)
        return npv

    def power(self, box, in_box=None, out_box=None):
        """
        Power measures how much of the prediction our explanation actually describes
        What we want to describe is the difference between a baseline and the prediction
        of our individual case. If 10% of rows fall into one class, our baseline for
        that class is 0.1

        We find how much our box describes by looking at the average prediction inside
        our box. The difference between that and the baseline is the increase our
        box can describe. The ratio of that increase to the individual increase is
        the power.

        Returns float between 0 and 1, higher is better. Note that it is theoretically
        possible to get a power greater than 1, where everything inside the
        explanation has a higher prediction than the point of interest. When
        this happens, we just set it to 1. It does describe the whole movement.

        :param box: Box to test
        :param in_box: Optional pre-compute of parts of the dataset inside the box
        :param out_box: Optional pre-compute of the dataset outside the box
        :returns: float between 0 and 1
        """
        LOGGER.debug("start power")

        if in_box is None or out_box is None:
            in_box = self.inside_box(box)
            out_box = self.weighted_df[~self.weighted_df.index.isin(in_box.index)]

        if in_box.empty or out_box.empty:
            LOGGER.warning(
                "Box {} had either nothing inside it or nothing outside it".format(box)
            )
            return 0

        in_box["weighted_probabilities"] = (
            in_box["probabilities"] * in_box["__weight__"]
        )
        out_box["weighted_probabilities"] = (
            out_box["probabilities"] * out_box["__weight__"]
        )
        self.weighted_df["weighted_probabilities"] = (
            self.weighted_df["probabilities"] * self.weighted_df["__weight__"]
        )

        inside_baseline = (
            in_box["weighted_probabilities"].sum() / in_box["__weight__"].sum()
        )
        outside_baseline = (
            out_box["weighted_probabilities"].sum() / out_box["__weight__"].sum()
        )

        power = min(
            max(
                (inside_baseline - outside_baseline)
                / (self.prediction - outside_baseline),
                0,
            ),
            1,
        )
        LOGGER.debug("power: %s", power)
        return power

    def coverage(self, box, in_box=None):
        """
        Coverage is a measure of how general our explanation is. A higher coverage means that the explanation applies to
        many "nearby" cases. Higher number is higher coverage, and is better

        :param box: Box to test
        :param in_box: Optional pre-compute of parts of the dataset inside the box
        :returns: float between 0 and 1
        """
        LOGGER.debug("start coverage")

        if in_box.empty:
            return 0

        if in_box is None:
            in_box = self.inside_box(box)

        weights_inside = sum(in_box["__weight__"])
        weights_total = sum(self.weighted_df["__weight__"])

        coverage = weights_inside / weights_total
        LOGGER.debug("coverage: %s", coverage)
        return coverage

    def parsimony(self, box):
        """
        Parsimony measures how simple our explanation is. The more features
        we use, the lower the parsimony. Simpler explanations, as long as they
        are also good ones, are better.

        Returns float between 0 and 1. Higher is better.

        :param box: The box we want to get the parsimony of
        :returns: float between 0 and 1, higher is better
        """

        LOGGER.debug("start parsimony")

        full = self.row.shape[1]
        used = len(box)

        parsimony = 1 - (used / full)
        LOGGER.debug("parsimony: %s", parsimony)
        return parsimony

    def gain(self, box, in_box=None, out_box=None):
        """
        Metric which measures the gain, the difference between precision and NPV. More precisely, it is precision -
        (1 - npv). It represents the information gain.

        :param out_box: Optional pre-compute of dataset outside box
        :param in_box: Optional pre-compute of dataset outside box
        :param box: Box dict
        :returns: Float between 0 and 1
        """
        LOGGER.debug("start gain")

        gain = max(
            self.precision(box, in_box) - (1 - self.npv(box, in_box, out_box)), 0
        )
        LOGGER.debug("gain: %s", gain)
        return gain

    def fidelity(self, box, in_box=None, out_box=None):
        """
        A combination of precision, npv, and power. Strength of the specificty
        of the describers. Similar to how f1 is the combination of precision and
        recall. Uses harmonic mean

        :param out_box: Optional pre-compute of dataset outside box
        :param in_box: Optional pre-compute of dataset outside box
        :param box: Box dict
        :returns: Float between 0 and 1
        """

        LOGGER.debug("start fidelity")

        precision = self.precision(box, in_box)
        NPV = self.npv(box, in_box, out_box)
        power = self.power(box, in_box, out_box)

        LOGGER.debug("{} {} {}".format(precision, NPV, power))

        if not (
            NPV > 0 and precision > 0 and power > 0
        ):  # Note that in rare these are nan
            return 0

        fidelity = stats.hmean([precision, NPV, power])
        LOGGER.debug("fidelity: %s", fidelity)
        return fidelity

    # All gower related functions appropriated from github:
    # https://stackoverflow.com/a/41706829
    def gower_distances(
        self, X, Y=None, feature_weight=None, categorical_features=None
    ):
        """Computes the gower distances between X and y

        Gower is a similarity measure for categorical, boolean and numerical mixed
        data.


        Parameters
        ----------
        X : array-like, or pandas.DataFrame, shape (n_samples, n_features)

        Y : array-like, or pandas.DataFrame, shape (n_samples, n_features)

        feature_weight :  array-like, shape (n_features)
            According the Gower formula, feature_weight is an attribute weight.

        categorical_features: array-like, shape (n_features)
            Indicates with True/False whether a column is a categorical attribute.
            This is useful when categorical atributes are represented as integer
            values. Categorical ordinal attributes are treated as numeric, and must
            be marked as false.

            Alternatively, the categorical_features array can be represented only
            with the numerical indexes of the categorical attribtes.

        Returns
        -------
        similarities : ndarray, shape (n_samples, n_samples)

        Notes
        ------
        The non-numeric features, and numeric feature ranges are determined from X and not y.
        No support for sparse matrices.

        """

        if issparse(X) or issparse(Y):
            raise TypeError("Sparse matrices are not supported for gower distance")

        # It is necessary to convert to ndarray in advance to define the dtype
        if not isinstance(X, np.ndarray):
            X = np.asarray(X)

        array_type = np.object
        # this is necessary as strangelly the validator is rejecting numeric
        # arrays with NaN
        if np.issubdtype(X.dtype, np.number) and (
            np.isfinite(X.sum()) or np.isfinite(X).all()
        ):
            array_type = type(np.zeros(1, X.dtype).flat[0])

        X, Y = self.check_pairwise_arrays(X, Y, precomputed=False, dtype=array_type)

        n_rows, n_cols = X.shape

        if categorical_features is None:
            categorical_features = np.zeros(n_cols, dtype=bool)
            for col in range(n_cols):
                # In numerical columns, None is converted to NaN,
                # and the type of NaN is recognized as a number subtype
                if not np.issubdtype(type(X[0, col]), np.number):
                    categorical_features[col] = True
        else:
            categorical_features = np.array(categorical_features)

        # if categorical_features.dtype == np.int32:
        if np.issubdtype(categorical_features.dtype, np.int):
            new_categorical_features = np.zeros(n_cols, dtype=bool)
            new_categorical_features[categorical_features] = True
            categorical_features = new_categorical_features

        print(categorical_features)

        # Categorical columns
        X_cat = X[:, categorical_features]

        # Numerical columns
        X_num = X[:, np.logical_not(categorical_features)]

        # Calculates the normalized ranges and max values of numeric values
        _, num_cols = X_num.shape
        ranges_of_numeric = np.zeros(num_cols)
        max_of_numeric = np.zeros(num_cols)
        for col in range(num_cols):
            col_array = X_num[:, col].astype(np.float32)
            max = np.nanmax(col_array)
            min = np.nanmin(col_array)

            if np.isnan(max):
                max = 0.0
            if np.isnan(min):
                min = 0.0
            max_of_numeric[col] = max
            ranges_of_numeric[col] = (1 - min / max) if (max != 0) else 0.0

        # This is to normalize the numeric values between 0 and 1.
        X_num = np.divide(
            X_num, max_of_numeric, out=np.zeros_like(X_num), where=max_of_numeric != 0
        )

        if feature_weight is None:
            feature_weight = np.ones(n_cols)

        feature_weight_cat = feature_weight[categorical_features]
        feature_weight_num = feature_weight[np.logical_not(categorical_features)]

        y_n_rows, _ = Y.shape

        dm = np.zeros((n_rows, y_n_rows), dtype=np.float32)

        feature_weight_sum = feature_weight.sum()

        if Y is not None:
            Y_cat = Y[:, categorical_features]
            Y_num = Y[:, np.logical_not(categorical_features)]
            # This is to normalize the numeric values between 0 and 1.
            Y_num = np.divide(
                Y_num,
                max_of_numeric,
                out=np.zeros_like(Y_num),
                where=max_of_numeric != 0,
            )
        else:
            Y_cat = X_cat
            Y_num = X_num

        for i in range(n_rows):
            j_start = i

            # for non square results
            if n_rows != y_n_rows:
                j_start = 0

            result = self._gower_distance_row(
                X_cat[i, :],
                X_num[i, :],
                Y_cat[j_start:n_rows, :],
                Y_num[j_start:n_rows, :],
                feature_weight_cat,
                feature_weight_num,
                feature_weight_sum,
                categorical_features,
                ranges_of_numeric,
                max_of_numeric,
            )
            dm[i, j_start:] = result
            dm[i:, j_start] = result

        return dm

    @staticmethod
    def _gower_distance_row(
        xi_cat,
        xi_num,
        xj_cat,
        xj_num,
        feature_weight_cat,
        feature_weight_num,
        feature_weight_sum,
        categorical_features,
        ranges_of_numeric,
        max_of_numeric,
    ):
        """Computes the gower distances for a single row -  internal to the gower function"""
        # categorical columns
        sij_cat = np.where(
            xi_cat == xj_cat, np.zeros_like(xi_cat), np.ones_like(xi_cat)
        )
        sum_cat = np.multiply(feature_weight_cat, sij_cat).sum(axis=1)

        # numerical columns
        abs_delta = np.absolute(xi_num - xj_num)
        sij_num = np.divide(
            abs_delta,
            ranges_of_numeric,
            out=np.zeros_like(abs_delta),
            where=ranges_of_numeric != 0,
        )

        sum_num = np.multiply(feature_weight_num, sij_num).sum(axis=1)
        sums = np.add(sum_cat, sum_num)
        sum_sij = np.divide(sums, feature_weight_sum)
        return sum_sij

    @staticmethod
    def check_pairwise_arrays(X, Y, precomputed=False, dtype=None):
        """Checking arrays are valid - Not sure why needed - toby special"""
        X, Y, dtype_float = pairwise._return_float_dtype(X, Y)

        warn_on_dtype = dtype is not None
        estimator = "check_pairwise_arrays"
        if dtype is None:
            dtype = dtype_float

        if Y is X or Y is None:
            X = Y = validation.check_array(
                X,
                accept_sparse="csr",
                dtype=dtype,
                warn_on_dtype=warn_on_dtype,
                estimator=estimator,
            )
        else:
            X = validation.check_array(
                X,
                accept_sparse="csr",
                dtype=dtype,
                warn_on_dtype=warn_on_dtype,
                estimator=estimator,
            )
            Y = validation.check_array(
                Y,
                accept_sparse="csr",
                dtype=dtype,
                warn_on_dtype=warn_on_dtype,
                estimator=estimator,
            )

        if precomputed:
            if X.shape[1] != Y.shape[0]:
                raise ValueError(
                    "Precomputed metric requires shape "
                    "(n_queries, n_indexed). Got (%d, %d) "
                    "for %d indexed." % (X.shape[0], X.shape[1], Y.shape[0])
                )
        elif X.shape[1] != Y.shape[1]:
            raise ValueError(
                "Incompatible dimension for X and y matrices: "
                "X.shape[1] == %d while y.shape[1] == %d" % (X.shape[1], Y.shape[1])
            )

        return X, Y
