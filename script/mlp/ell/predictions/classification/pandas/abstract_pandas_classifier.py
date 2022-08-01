"""
Contains an abstract base class for clasification models so we
can standardize our interfaces with them.
"""
import abc
import gc
import logging
import os
import random
from abc import ABC
from typing import ClassVar, Optional, Sequence, Tuple, Union

import numpy as np
import pandas as pd
from sklearn.metrics import (
    f1_score,
    precision_score,
    recall_score,
)

from ..classifier_abc import AbstractClassifier
from ..scores import Scores

LOGGER = logging.getLogger(__name__)

GB = 1 << 30


class AbstractPandasClassifier(AbstractClassifier, ABC):
    """ABC for classifiers which uses Pandas data structures as inputs
    and outputs.

    This class also provides a framework for batch-fitting models.

    """

    WARM_START: ClassVar[bool] = False

    def __init__(self, config: Optional[dict] = None):
        """Initialize abstract classification class.

        Args:
            config (dict): Dictionary containing all settings for this
                model.

        """
        super().__init__(config)
        self.cutpoint = 0.5  # Classification cutpoint probability
        self.num_epochs = 1
        self.num_classes = 2

    def fit(self, dataset: Union[pd.DataFrame, Sequence[pd.DataFrame]]) -> None:
        """Fit this model to a training dataset."""
        LOGGER.debug("Started the fit method")

        # Set seed for reproducibility
        self.set_training_seeds()

        # Make sure dataset is always a Sequence[pd.DataFrame]
        if isinstance(dataset, pd.DataFrame):
            dataset = [dataset]

        if (len(dataset) > 1 or self.num_epochs > 1) and not self.WARM_START:
            raise ValueError(
                f"Batch fitting is not supported on non-warm-start models such as "
                f"{type(self).__name__}"
            )

        LOGGER.info("Starting the fit loop")
        for epoch in range(1, self.num_epochs + 1):
            LOGGER.debug("Starting epoch %s of %s", epoch, self.num_epochs)
            for df in dataset:
                LOGGER.debug(
                    "DataFrame shape: %s. Memory usage: %.3f GB",
                    df.shape,
                    df.memory_usage(deep=True).sum() / GB,
                )
                # Split into X and y
                X = df.drop(columns=[self.target])
                y = df[self.target]
                # Clean up df if possible
                del df
                gc.collect()

                # Let the subclass do the actual fitting
                self._fit(X, y)

        if self.calibrator is not None:
            LOGGER.info("Calibrating model")
            proba_dfs = []
            for df in dataset:
                # Split X out from DataFrame
                X = df.drop(columns=[self.target])
                # Clean up df if possible
                del df
                gc.collect()

                proba_df = self._predict_proba(X)
                proba_dfs.append(proba_df)
            proba_df = pd.concat(proba_dfs)

            self.calibrator.fit(proba_df)
            LOGGER.info("Completed calibration of raw probabilities")

        LOGGER.info("Completed the fit loop")

    @abc.abstractmethod
    def _fit(self, X: pd.DataFrame, y: pd.Series) -> None:
        """Fit the model to the data.

        Args:
            X: Input samples with features only.
            y: Class classes for the input samples.

        """
        raise NotImplementedError

    def set_training_seeds(self):
        """Set random seed for everything before training"""
        LOGGER.debug("Setting training seeds")

        if "random_state" in self.parameters:
            seed = self.parameters["random_state"]
        elif "seed" in self.parameters:
            seed = self.parameters["seed"]
        else:
            seed = 0
            self.parameters["random_state"] = seed
            self.parameters["seed"] = seed

        os.environ["PYTHONHASHSEED"] = str(seed)
        random.seed(seed)
        np.random.seed(seed)

    def predict(
        self,
        dataset: Union[pd.DataFrame, Sequence[pd.DataFrame]],
        *,
        return_labels=False,
    ) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """Transform the input samples and predict.

        Args:
            dataset: The input samples to predict.
            return_labels (bool): When True, the returned dataframe
                containing categories will also contain the classes for
                the input samples (if the input samples are indeed
                labelled).

        Returns:
            Tuple[pd.DataFrame, pd.DataFrame]: A DataFrame of class
            confidences (a.k.a. probabilities), and a dataframe
            containing the predicted class for each sample (a.k.a.
            categories) under column "category", and optionally the
            classes for each input sample (if ``return_labels`` is
            True and the input samples are actually labelled) under the
            column "label".

        """
        if isinstance(dataset, pd.DataFrame):
            dataset = [dataset]
        LOGGER.info("Predicting on a dataset of %s batches", len(dataset))
        proba_dfs = []
        # y_series_list is a list of pandas.Series objects, each being
        # a series of labels.
        y_series_list = []

        for df in dataset:
            if self.target in df.columns:
                X = df.drop(columns=[self.target])
            else:
                X = df
            proba_df = self._predict_proba(X)
            if return_labels and self.target in df.columns:
                y = df[self.target]
                y_series_list.append(y)
            proba_dfs.append(proba_df)

        proba_df = pd.concat(proba_dfs)

        if self.calibrator is not None:
            proba_df = self.calibrator.transform(proba_df)
            LOGGER.info("Completed calibration of probabilities")

        cat_series = self._classify_raw_predictions(proba_df)
        cat_df = cat_series.to_frame(name="category")
        if return_labels and y_series_list:
            label_series = pd.concat(y_series_list).rename("label")
            cat_df = cat_df.join(label_series)

        LOGGER.info("Predicting finished")
        return proba_df, cat_df

    def _classify_raw_predictions(self, proba_df: pd.DataFrame) -> pd.Series:
        if proba_df.shape[1] == 2:
            # In a binary classification problem, we use the (possibly
            # optimised) cutpoint to transform probabilities into
            # categories.
            class0 = proba_df.columns[0]
            class1 = proba_df.columns[1]
            cat_array = np.where(proba_df[class1] > self.cutpoint, class1, class0)
            cat_series = pd.Series(cat_array, index=proba_df.index, name="category")
        else:
            # In a multi-class problem, we simply assign the class which
            # has the highest confidence.
            cat_series = proba_df.idxmax(axis="columns")

        return cat_series

    @abc.abstractmethod
    def _predict_proba(self, X: pd.DataFrame) -> pd.DataFrame:
        raise NotImplementedError

    @abc.abstractmethod
    def reset(self):
        """Initialise the model"""
        raise NotImplementedError

    def score(
        self,
        dataset: Union[pd.DataFrame, Sequence[pd.DataFrame]],
    ) -> dict:
        """Compute various evaluation metrics.

        Args:
            dataset: Labelled test samples to score the model against.

        Returns:
            dict: A dictionary containing all the metrics.

        """
        LOGGER.info("Scoring model")
        proba_df, cats_df = self.predict(dataset, return_labels=True)
        y_pred = cats_df["category"]
        y_true = cats_df.drop(columns=["category"]).iloc[:, 0]

        scores = Scores.calculate(
            y_true,
            y_pred,
            proba_df,
            classes=proba_df.columns.to_list(),
        ).to_dict()

        LOGGER.info("Finished scoring model", extra={"data": scores})
        return scores

    def optimise_threshold(
        self,
        dataset: Union[pd.DataFrame, Sequence[pd.DataFrame]],
        *,
        cutoff: Optional[Union[str, float]] = None,
    ) -> None:
        LOGGER.info("Predicting samples from optimise dataset")
        proba_df, cat_df = self.predict(dataset, return_labels=True)
        class1_probs: pd.Series = proba_df.iloc[:, 1]
        Y = cat_df.drop(columns=["category"])

        if cutoff == "churn":
            LOGGER.debug(f"optimise = churn, setting decision boundary to churn rate")
            self.cutpoint = class1_probs.quantile(1 - Y.mean()).iloc[0]
        elif isinstance(cutoff, float):
            percentage = cutoff
            LOGGER.debug(
                "optimise = %s, setting decision boundary to top %s",
                percentage,
                f"{percentage:.1%}",
            )
            if not 0 < percentage < 1:
                raise ValueError(
                    f"Percentage should be between 0 and 1, you gave {percentage}"
                )
            self.cutpoint = class1_probs.quantile(1 - percentage)
        else:
            LOGGER.info("Optimising cutpoint (assumes binary classification)")
            # Round preds to avoid overfitting and cut computation time
            class1_probs = class1_probs.round(3)
            unique_probs: pd.Series = class1_probs.drop_duplicates()
            LOGGER.debug("Optimising over %s thresholds", len(unique_probs))

            # Loop over unique probability
            LOGGER.debug("Optimising over %s thresholds", len(unique_probs))
            f1_scores = []

            for i, cutpoint in enumerate(unique_probs, 1):
                cats = class1_probs.ge(cutpoint).astype("int32")

                # Calc scores
                f1 = f1_score(Y, cats, labels=range(0, self.num_classes))
                precision = precision_score(Y, cats, labels=range(0, self.num_classes))
                recall = recall_score(Y, cats, labels=range(0, self.num_classes))

                # Logging for f1=0 branch. Only counts if precision_min or recall_max is set
                if "precision_min" in self.parameters.keys():
                    LOGGER.debug("precision_min in keys")
                    asd = self.parameters.get("precision_min", 0)
                    LOGGER.debug("precision_min in keys, precision_min = %s", asd)
                if "recall_max" in self.parameters.keys():
                    asd = self.parameters.get("recall_max", 1)
                    asd2 = recall
                    LOGGER.debug(
                        "recall_max in keys, recall max = %s, scores['recall'] = %s",
                        asd,
                        asd2,
                    )
                    if recall < self.parameters.get("recall_max", 1):
                        LOGGER.debug("Should go to tmp1: scores < recall_max")
                    else:
                        LOGGER.debug(
                            "Should go to tmp1 but cant because: scores >= recall_max"
                        )

                condition_1 = not (
                    "recall_max" in self.parameters.keys()
                    and recall < self.parameters.get("recall_max", 1)
                )
                condition_2 = not (
                    "precision_min" not in self.parameters.keys()
                    and "recall_max" not in self.parameters.keys()
                )
                condition_3 = not (
                    "precision_min" in self.parameters.keys()
                    and precision > self.parameters.get("precision_min", 0)
                )

                if condition_1 and condition_2 and condition_3:
                    f1 = 0
                    LOGGER.debug(
                        "Warning setting f1=0 - are you in the wrong branch due to "
                        "recall_max or precision_min?"
                    )

                f1_scores.append([cutpoint, f1])

                if i % 100 == 0:
                    LOGGER.debug("Finished cutpoint %s", i)

            LOGGER.debug("Finding optimal")
            f1_scores = np.array(f1_scores)
            LOGGER.debug("f1 scores for each cutpoint", extra={"data": f1_scores})
            optimal_index = f1_scores.argmax(axis=0)[1]
            optimal_threshold = f1_scores[optimal_index][0]

            self.cutpoint = optimal_threshold

            LOGGER.debug("Optimal f1 score: %s", f1_scores[optimal_index][1])

        LOGGER.debug(f"New cutpoint = %s", self.cutpoint)

    def predict_probabilities(
        self, dataset: Union[pd.DataFrame, Sequence[pd.DataFrame]]
    ) -> np.ndarray:
        proba_df, cats = self.predict(dataset)
        return proba_df.to_numpy(dtype="float64")

    def predict_categories(
        self, dataset: Union[pd.DataFrame, Sequence[pd.DataFrame]]
    ) -> np.ndarray:
        proba_df, cats = self.predict(dataset)
        return cats["category"].to_numpy(dtype="int32")
