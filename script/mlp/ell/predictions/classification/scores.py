"""Module for utilities which evaluate classifiers."""
__all__ = ["Scores", "calculate_lift", "calculate_precision", "calculate_gini"]

import dataclasses
from typing import Any, Dict, Optional, Sequence, Tuple

import numpy as np
import pandas as pd
from sklearn.metrics import (
    confusion_matrix,
    f1_score,
    log_loss,
    precision_score,
    roc_auc_score,
)


@dataclasses.dataclass(frozen=True)
class Scores:
    """Dataclass containing standard metrics for binary classification."""

    accuracy: float
    f_1: float
    precision: float
    recall: float
    log_loss: float
    churn_rate: float
    confusion_matrix: Dict[str, int]
    lift_1: float
    lift_2: float
    lift_5: float
    lift_10: float
    lift_20: float
    lift_churn_rate: float
    precision_1: float
    precision_2: float
    precision_5: float
    precision_10: float
    precision_20: float
    gini_coefficient: float

    @classmethod
    def calculate(
        cls,
        y_true: pd.Series,
        y_pred: pd.Series,
        probas: pd.DataFrame,
        *,
        classes: Optional[Sequence[Any]] = None,
    ) -> "Scores":
        """Calculate the scores from the given labels and predictions.

        Args:
            y_true: Series of true labels.
            y_pred: Series of predicted classes.
            probas: DataFrame of raw predictions for each class.
            classes: All unique classes which can appear in y_true
                and/or y_pred.

        """
        tn, fp, fn, tp = confusion_matrix(y_true, y_pred, labels=classes).ravel()

        confusion_matrix_ = {
            "true negative": int(tn),
            "false positive": int(fp),
            "false negative": int(fn),
            "true positive": int(tp),
        }

        f_1 = f1_score(y_true, y_pred, labels=classes)
        log_loss_score = log_loss(y_true, y_pred, labels=classes)

        precision = tp / (tp + fp)
        recall = tp / (tp + fn)

        accuracy = (tp + tn) / (tp + fp + tn + fn)

        pos_proba = probas.iloc[:, 1]

        lift_1, lift_2, lift_5, lift_10, lift_20, lift_churn_rate = calculate_lift(
            y_true, pos_proba
        )

        prec_1, prec_2, prec_5, prec_10, prec_20 = calculate_precision(
            y_true, pos_proba
        )

        gini_coefficient = calculate_gini(y_true, pos_proba)

        # Need to explicitly cast to float as we do not know the dtype of the label
        churn_rate = float(y_true.mean())

        return cls(
            f_1=f_1,
            accuracy=accuracy,
            precision=precision,
            recall=recall,
            log_loss=log_loss_score,
            churn_rate=churn_rate,
            confusion_matrix=confusion_matrix_,
            lift_1=lift_1,
            lift_2=lift_2,
            lift_5=lift_5,
            lift_10=lift_10,
            lift_20=lift_20,
            lift_churn_rate=lift_churn_rate,
            precision_1=prec_1,
            precision_2=prec_2,
            precision_5=prec_5,
            precision_10=prec_10,
            precision_20=prec_20,
            gini_coefficient=gini_coefficient,
        )

    def to_dict(self) -> Dict[str, Any]:
        """Convert this Scores object to a dictionary."""
        return dataclasses.asdict(self)

    def to_df(self, dataset_name: Optional[str] = None) -> pd.DataFrame:
        """Convert this Scores object to a Pandas DataFrame.

        The DataFrame will have metric names as the columns, and metric
        values as the values. The index will be the name of the dataset,
        if ``dataset_name`` is provided.
        """
        scores_dict = self.to_dict()
        confusion_matrix_ = scores_dict.pop("confusion_matrix")
        for key, value in confusion_matrix_.items():
            scores_dict[key.replace(" ", "_")] = value
        index = dataset_name and pd.Index([dataset_name], name="dataset")
        return pd.DataFrame(scores_dict, index=index)

    @classmethod
    def get_glue_schema(cls) -> Dict[str, str]:
        """Get the Glue schema for a scores dataframe."""
        schema = {"dataset": "string"}
        schema.update(
            {
                attr: "double"
                for attr, dtype in cls.__annotations__.items()
                if dtype is float
            }
        )
        schema.update(
            true_negative="int",
            false_positive="int",
            false_negative="int",
            true_positive="int",
        )
        return schema


def calculate_lift(
    y_true: pd.Series, pos_proba: pd.Series
) -> Tuple[float, float, float, float, float, float]:
    """Calculate lift scores at 1%, 2%, 5%, 10%, 20%, and the churn
    rate (i.e. positive case rate, as it appears in the true labels).

    Notes:
        Only works for binary classification.

    Args:
        y_true: Actual class classes of test data
        pos_proba: Predicted positive-case probabilities of test data

    Returns:
        Lift at 1%, 2%, 5%, 10%, 20%

    """
    if isinstance(y_true, pd.Series):
        y_true = y_true.to_numpy()
    if isinstance(pos_proba, pd.Series):
        pos_proba = pos_proba.to_numpy()

    data = np.stack((y_true, pos_proba), axis=-1)

    df = pd.DataFrame(data, columns=["true", "probability"])
    baseline = df["true"].sum() / float(len(df))

    df = df.sort_values(by="probability", ascending=False)

    df_1 = df[: int(len(df) / 100)]

    df_2 = df[: int(len(df) / 50)]

    df_5 = df[: int(len(df) / 20)]

    df_10 = df[: int(len(df) / 10)]

    df_20 = df[: int(len(df) / 5)]

    churn_rate = y_true.mean()
    df_churn = df[: int(len(df) * churn_rate)]

    dfs = [df_1, df_2, df_5, df_10, df_20, df_churn]
    lift_scores = []
    for df in dfs:
        pre = precision_score(df["true"], np.ones(len(df["true"])))
        lift_scores.append(pre / baseline)

    lift_1, lift_2, lift_5, lift_10, lift_20, lift_churn_rate = lift_scores

    return lift_1, lift_2, lift_5, lift_10, lift_20, lift_churn_rate


def calculate_precision(
    y_true: pd.Series, pos_proba: pd.Series
) -> Tuple[float, float, float, float, float]:
    """Calculates the precision at a range of thresholds.

    Notes:
        Only works for binary classification.

    Args:
        y_true (pd.Series or np.ndarray): The true class classes
        pos_proba (pd.Series or np.ndarray): The predicted
            probabilities for each sample

    Returns:
        list[float]: Precision score at 1%, 2%, 5%, 10%, 20% thresholds
    """
    if isinstance(y_true, pd.Series):
        y_true = y_true.to_numpy()
    if isinstance(pos_proba, pd.Series):
        pos_proba = pos_proba.to_numpy()

    # TODO make this work multiclass
    data = np.stack((y_true, pos_proba), axis=-1)

    df = pd.DataFrame(data, columns=["true", "probability"])

    df = df.sort_values(by="probability", ascending=False)

    # Get list of df at different thresholds (1%, 2%, 5%, 10%, 20%)
    dfs = [df.head(int(frac * len(df))) for frac in [0.01, 0.02, 0.05, 0.1, 0.2]]

    precision_scores = []
    for df in dfs:
        # Get precision if we predict entire cutpoint as true
        pre = precision_score(df["true"], np.ones(len(df["true"])))
        precision_scores.append(pre)

    prec_1, prec_2, prec_5, prec_10, prec_20 = precision_scores
    return prec_1, prec_2, prec_5, prec_10, prec_20


def calculate_gini(y_true: pd.Series, pos_proba: pd.Series) -> float:
    """Calculate gini score from predicted probabilities.

    Notes:
        Only works for binary classification.

    Args:
        y_true: True classes or binary label indicators. The binary and
            multiclass cases expect classes with shape ``(n_samples,)``.
        pos_proba: Target scores. In the binary and multilabel cases,
            these can be either probability estimates or non-thresholded
            decision values. In the multiclass case, these must be
            probability estimates which sum to 1. The binary case
            expects the shape ``(n_samples,)``, and the scores must be
            the scores of the class with the greater label.

    Returns:
        The gini score of the predictions

    """
    # TODO make this work multiclass
    auc = roc_auc_score(y_true, pos_proba)
    return 2.0 * auc - 1
