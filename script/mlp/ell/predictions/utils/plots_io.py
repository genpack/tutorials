"""Utilities for storing plots."""

__all__ = ["persist_plots"]

import logging
from typing import Dict

import matplotlib.pyplot as plt
from ell.env.env_abc import AbstractEnv
from ell.env.uri import URI

from ell.predictions import compat

LOGGER = logging.getLogger(__name__)


def persist_plots(
    figures: Dict[str, plt.Figure], output_path: URI, env: AbstractEnv = compat.env
) -> None:
    """Persist standard plots to the given directory."""
    LOGGER.info("Persisting %s plots to %r", len(figures), output_path)

    filesystem = env.get_fs_for_uri(output_path)

    for fname, figure in figures.items():
        with filesystem.open(output_path.file(f"{fname}.png"), "wb") as f:
            figure.savefig(f, bbox_inches="tight")
