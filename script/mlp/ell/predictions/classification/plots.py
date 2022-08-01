"""Module for plotting classification outputs or metrics."""
from typing import Tuple

import pandas as pd
import scikitplot
import seaborn
from matplotlib import pyplot


def get_standard_plots(
    y_true: pd.Series, proba_df: pd.DataFrame
) -> Tuple[pyplot.Figure, pyplot.Figure, pyplot.Figure]:
    """Get the standard plots we use for *binary* classification.

    This returns three figures:

    #. Cumulative gain curve
    #. Lift curve
    #. Distribution of predicted probabilities

    Args:
        y_true (pandas.Series): Series of true classes for each sample
            (shape ``(n_samples,)``).
        proba_df (pandas.DataFrame): DataFrame of probabilities for each
            class (shape ``(n_samples, n_classes)``). Note that only
            binary classification is supported.

    Returns:
        tuple: Three :class:`matplotlib.pyplot.Figure` objects, in the
        order mentioned above.

    """
    if proba_df.shape[1] > 2:
        raise NotImplementedError("Multi-class is unsupported by get_standard_plots()")

    y_true = y_true.rename("y_true")

    cumgain_fig, cumgain_ax = pyplot.subplots()
    scikitplot.metrics.plot_cumulative_gain(y_true, proba_df, ax=cumgain_ax)

    lift_fig, lift_ax = pyplot.subplots()
    scikitplot.metrics.plot_lift_curve(y_true, proba_df, ax=lift_ax)

    dist_fig, dist_ax = pyplot.subplots()
    dist_ax.set_title("Distribution of Predicted Probabilities")

    y_proba = proba_df.iloc[:, 1]
    df = pd.concat([y_proba, y_true], axis="columns")
    pos_proba = df[df["y_true"] == y_proba.name][y_proba.name]
    seaborn.distplot(
        pos_proba,
        hist=False,
        rug=False,
        label="Positive Case",
        axlabel=False,
        ax=dist_ax,
        color="r",
    )
    neg_proba = df[df["y_true"] != y_proba.name][y_proba.name]
    seaborn.distplot(
        neg_proba,
        hist=False,
        rug=False,
        label="Negative Case",
        axlabel=False,
        ax=dist_ax,
        color="b",
    )
    return cumgain_fig, lift_fig, dist_fig
