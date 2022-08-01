"""Utilities for storing and retrieving prediction DataFrames."""

__all__ = ["persist_predictions", "persist_prediction_scores_df"]

import logging

import pandas as pd
import pyarrow as pa
from ell.env.env_abc import AbstractEnv

from ell.predictions import compat

LOGGER = logging.getLogger(__name__)


def persist_predictions(
    uri: str, proba_df: pd.DataFrame, cats_df: pd.DataFrame, env: AbstractEnv = compat.env
) -> None:
    """Persist predictions as Parquet."""
    LOGGER.info("Persisting predictions to %r", uri)

    schema = pa.schema(
        [
            pa.field("caseID", pa.string(), False),
            pa.field("eventTime", pa.date32(), False),
        ]
    )

    if proba_df.shape[1] <= 2:
        LOGGER.debug(
            "No more than two classes in probability DataFrame - assuming the last one "
            "is the positive case"
        )
        proba_series = proba_df.iloc[:, -1].rename("probability")
        df = pd.concat([proba_series, cats_df], axis="columns")

        schema = schema.append(pa.field(proba_series.name, pa.float32(), True))
    else:
        LOGGER.debug("Found more than 2 classes in probability DataFrame")
        proba_df = proba_df.add_prefix("probability_")
        df = proba_df.join(cats_df)

        for colname in proba_df.columns:
            schema = schema.append(pa.field(colname, pa.float32(), True))

    # noinspection PyArgumentList
    cats_schema = pa.Schema.from_pandas(cats_df.reset_index(drop=True))

    for field in cats_schema:
        schema = schema.append(field)

    df = df.reset_index()
    filesystem = env.get_fs_for_uri(uri)
    with filesystem.open(uri, "wb") as f:
        df.to_parquet(f, index=None, flavor="spark", schema=schema)


def persist_prediction_scores_df(
    scores_df: pd.DataFrame, uri: str, env: AbstractEnv = compat.env
) -> None:
    """Persist prediction scores as Parquet."""
    LOGGER.info("Persisting prediction scores to %r", uri)

    filesystem = env.get_fs_for_uri(uri)
    with filesystem.open(uri, "wb") as f:
        scores_df.to_parquet(f, flavor="spark")
