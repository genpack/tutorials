import os
from pathlib import Path

import pytest
import yaml

try:
    import lightgbm
except ModuleNotFoundError:
    lightgbm = None
try:
    import torch
except ModuleNotFoundError:
    torch = None
try:
    import xgboost
except ModuleNotFoundError:
    xgboost = None
try:
    import ray
except ModuleNotFoundError:
    ray = None

_TESTCASES_DIR = Path(__file__).parent.joinpath("testcases")
_SKIP_MARKS = {
    "lightgbm_unavailable": pytest.mark.skipif(
        lightgbm is None, reason="lightgbm is not installed"
    ),
    "torch_unavailable": pytest.mark.skipif(
        torch is None, reason="torch is not installed"
    ),
    "xgb_unavailable": pytest.mark.skipif(
        xgboost is None, reason="xgboost is not installed"
    ),
    "ray_unavailable": pytest.mark.skipif(
        ray is None, reason="ray tune is not installed"
    ),
    "on_windows": pytest.mark.skipif(
        os.name == "nt", reason="Test disabled on Windows"
    ),
}


def _load_testcases(category: str) -> list:
    testcases = []
    for pred_config_pth in _TESTCASES_DIR.joinpath(category).iterdir():
        with pred_config_pth.open() as f:
            pred_config = yaml.safe_load(f)

        marks = []

        skip_condition = pred_config.pop("skip_if", None)
        if isinstance(skip_condition, list):
            marks.extend(_SKIP_MARKS[condition] for condition in skip_condition)
        elif skip_condition is not None:
            marks.append(_SKIP_MARKS[skip_condition])

        if pred_config.get("xfail"):
            marks.append(pytest.mark.xfail())

        testcases.append(
            pytest.param(pred_config, marks=marks, id=pred_config_pth.stem)
        )

    return testcases


classification = _load_testcases("classification")
explanation = _load_testcases("explanation")
hpo = _load_testcases("hpo")
