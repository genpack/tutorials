__all__ = ["persist_explanations", "persist_englishing", "persist_scores"]

import itertools
import logging

import pandas as pd
import pyarrow as pa
from ell.env.env_abc import AbstractEnv

from ell.describers import compat

LOGGER = logging.getLogger(__name__)

EXPLANATIONS_SCHEMA = pa.schema(
    [
        pa.field("caseID", pa.string(), False),
        pa.field("eventTime", pa.date32(), False),
        pa.field("explanation_number", pa.int64(), False),
        pa.field("feature", pa.string(), False),
        pa.field("upper", pa.float64(), True),
        pa.field("lower", pa.float64(), True),
        pa.field("actual", pa.float64(), False),
    ]
)
ENGLISHING_SCHEMA = pa.schema(
    [
        pa.field("caseID", pa.string(), False),
        pa.field("eventTime", pa.date32(), False),
        pa.field("explanation_number", pa.int64(), False),
        pa.field("unformatted_reason", pa.string(), False),
        pa.field("reason", pa.string(), False),
        pa.field("conversation", pa.string(), True),
    ]
)
SCORES_SCHEMA = pa.schema(
    [
        pa.field("caseID", pa.string(), False),
        pa.field("eventTime", pa.date32(), False),
        pa.field("final", pa.bool_(), False),
        pa.field("precision", pa.float64(), False),
        pa.field("npv", pa.float64(), False),
        pa.field("power", pa.float64(), False),
        pa.field("coverage", pa.float64(), False),
        pa.field("parsimony", pa.float64(), False),
        pa.field("gain", pa.float64(), False),
        pa.field("fidelity", pa.float64(), False),
    ]
)


def persist_explanations(df: pd.DataFrame, uri: str, env: AbstractEnv = compat.env) -> None:
    LOGGER.info("Persisting explanations to %r", uri)
    _persist_output(df, uri, EXPLANATIONS_SCHEMA, env)


def persist_englishing(df: pd.DataFrame, uri: str, env: AbstractEnv = compat.env) -> None:
    LOGGER.info("Persisting englishing to %r", uri)
    _persist_output(df, uri, ENGLISHING_SCHEMA, env)


def persist_scores(df: pd.DataFrame, uri: str, env: AbstractEnv = compat.env) -> None:
    LOGGER.info("Persisting scores to %r", uri)
    _persist_output(df, uri, SCORES_SCHEMA, env)


def _persist_output(df: pd.DataFrame, uri: str, schema: pa.Schema, env: AbstractEnv) -> None:
    if df.empty:
        LOGGER.warning("Empty DataFrame being persisted to %r!", uri)
        if df.shape[1] == 0:
            # Assign column names to empty dataframe.
            # We make everything object type since pyarrow doesn't mind
            # converting from object to anything else.
            df = df.assign(**dict(zip(schema.names, itertools.repeat([])))).astype(
                "object"
            )

    filesystem = env.get_fs_for_uri(uri)

    with filesystem.open(uri, "wb") as f:
        df[schema.names].to_parquet(f, index=None, flavor="spark", schema=schema)
