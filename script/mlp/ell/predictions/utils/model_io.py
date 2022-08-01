"""Utilities for storing and retrieving models to/from the file-system."""

__all__ = ["load_model"]

import logging
import os
from typing import TYPE_CHECKING

import joblib
from ell.env.env_abc import AbstractEnv

from ell.predictions import compat
from .utils import ensure_uri

if TYPE_CHECKING:
    from ell.predictions import Model

LOGGER = logging.getLogger(__name__)


def load_model(uri: str, env: AbstractEnv = compat.env) -> "Model":
    """Load a model with JobLib."""
    from ell.predictions import Model

    uri = ensure_uri(uri)
    filesystem = env.get_fs_for_uri(uri)

    if uri.endswith("/"):
        # If it's a directory, load the first "*.pkl" file in it
        glob_result = filesystem.glob(uri.file("*.pkl"), detail=False)
        if not glob_result:
            raise FileNotFoundError(f"Couldn't find a pickled model in {uri!r}")
        uri = uri.file(os.path.basename(glob_result[0]))

    LOGGER.info("Loading model from %r", uri)
    with filesystem.open(uri, "rb") as f:
        model = joblib.load(f)
    if not isinstance(model, Model):
        raise TypeError(
            f"Expected loaded object to be of type AbstractClassifier, but got "
            f"{model.__class__.__name__}"
        )
    LOGGER.info("Model loaded")
    return model
