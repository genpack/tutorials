"""Constants for compatibility between local and cloud environments."""
__all__ = [
    "ON_ECS",
    "ON_GLUE",
    "ON_DESCRIBERS_CONTAINER",
    "ON_DESCRIBERS_ETL",
    "env",
    "WORKSPACE_NAME",
    "ACCOUNT_ID",
    "RUN",
    "PARTITION_ID",
    "ATTEMPT_NUMBER",
]

import os
import re
import sys
from typing import Optional

from ell.predictions.compat import (
    ACCOUNT_ID,
    WORKSPACE_NAME,
    ON_ECS,
    ON_DESCRIBERS_CONTAINER,
    ON_DESCRIBERS_ETL,
    ON_GLUE,
    env,
)

RUN: Optional[str]
PARTITION_ID: Optional[int]
ATTEMPT_NUMBER: Optional[int]

if ON_DESCRIBERS_CONTAINER:
    RUN = os.environ["runid"]
    PARTITION_ID = int(os.environ["partition_id"])
    ATTEMPT_NUMBER = int(os.environ["attempt_number"])
elif ON_DESCRIBERS_ETL:
    _config_uri = sys.argv[sys.argv.index("--config") + 1]
    RUN = re.search(r"/run=([\w-]*)/", _config_uri)[1]
else:
    RUN = None
    PARTITION_ID = None
    ATTEMPT_NUMBER = None
