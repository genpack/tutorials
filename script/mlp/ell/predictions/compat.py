"""Constants for compatibility between local and cloud environments."""
__all__ = [
    "ON_ECS",
    "ON_GLUE",
    "ON_DESCRIBERS_CONTAINER",
    "ON_DESCRIBERS_ETL",
    "ON_PREDICTIONS_CONTAINER",
    "env",
    "WORKSPACE_NAME",
    "ACCOUNT_ID",
    "EXECUTORRUN",
    "MODULERUN",
]

import os
import re
import sys
from typing import Optional

from ell.env import ECSEnv, GlueEnv, LocalEnv
from ell.env.env_abc import AbstractEnv

ON_DESCRIBERS_CONTAINER = bool(
    os.getenv("runid") and os.getenv("partition_id") and os.getenv("attempt_number")
)
ON_PREDICTIONS_CONTAINER = bool(os.getenv("config") and os.getenv("meta"))
ON_ECS = ON_DESCRIBERS_CONTAINER or ON_PREDICTIONS_CONTAINER
ON_DESCRIBERS_ETL = bool("--config" in sys.argv and "--meta" in sys.argv)
ON_GLUE = ON_DESCRIBERS_ETL
env: AbstractEnv
WORKSPACE_NAME: Optional[str]
ACCOUNT_ID: Optional[str]
EXECUTORRUN: Optional[str]
MODULERUN: Optional[str]

if ON_ECS:
    env = ECSEnv()

    WORKSPACE_NAME = os.environ["name"]
    ACCOUNT_ID = os.environ["account_number"]
elif ON_GLUE:
    env = GlueEnv()

    WORKSPACE_NAME = sys.argv[sys.argv.index("--workspace-name") + 1]
    ACCOUNT_ID = sys.argv[sys.argv.index("--workspace-number") + 1]
else:
    # Setting spark_session to False prevents the creation of a
    # SparkSession, since we don't require it at this time.
    # noinspection PyTypeChecker
    env = LocalEnv(spark_session=False)

    WORKSPACE_NAME = None
    ACCOUNT_ID = None

if ON_PREDICTIONS_CONTAINER:
    EXECUTORRUN = re.search(r"/executorrun=([\w-]*)/", os.environ["config"])[1]
    MODULERUN = re.search(r"/modulerun=([\w-]*)/", os.environ["config"])[1]
else:
    EXECUTORRUN = None
    MODULERUN = None
