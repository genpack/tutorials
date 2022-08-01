import os
import random
import shutil
import sys
from typing import Dict

import joblib
import pandas as pd
import pytest
from ell.env.uri import URI

import ell.predictions
from ell.predictions import compat
from .data import (
    DATASET_CATEGORICAL_ENCODINGS,
    DATASET_MLSAMPLER_INFER,
    DATASET_MLSAMPLER_TEST,
    DATASET_MLSAMPLER_TRAIN,
)
from . import testcases

random.seed(42)


@pytest.fixture()
def setup(tmp_path_factory):
    train_modulerun_path = tmp_path_factory.mktemp(
        basename="train.modulerun=", numbered=True
    )
    infer_modulerun_path = tmp_path_factory.mktemp(
        basename="infer.modulerun=", numbered=True
    )
    data_path = tmp_path_factory.mktemp(basename="sampled.run=", numbered=True)

    # Prepare train data dir
    train_path = data_path.joinpath("train")
    train_path.mkdir(parents=True, exist_ok=True)
    df = pd.DataFrame.from_dict(DATASET_MLSAMPLER_TRAIN)
    df.to_parquet(train_path.joinpath(f"data.parquet"), row_group_size=df.shape[0] // 3)

    # Prepare test data dir
    test_path = data_path.joinpath("test")
    test_path.mkdir(parents=True, exist_ok=True)
    df = pd.DataFrame.from_dict(DATASET_MLSAMPLER_TEST)
    df.to_parquet(test_path.joinpath("data.parquet"))

    # Prepare optimise data dir
    optimise_path = data_path.joinpath("optimise")
    optimise_path.mkdir(parents=True, exist_ok=True)
    df = pd.DataFrame.from_dict(DATASET_MLSAMPLER_TEST)
    df.to_parquet(optimise_path.joinpath("data.parquet"))

    # Prepare infer data dir
    infer_path = data_path.joinpath("infer")
    infer_path.mkdir(parents=True, exist_ok=True)
    df = pd.DataFrame.from_dict(DATASET_MLSAMPLER_INFER)
    df.to_parquet(infer_path.joinpath("data.parquet"))

    # Prepare encodings file
    compat.env.write_jsonish(
        str(data_path.joinpath("categorical_encodings.json")),
        DATASET_CATEGORICAL_ENCODINGS,
    )

    yield {
        "train_modulerun_path": URI(f"{train_modulerun_path}/"),
        "infer_modulerun_path": URI(f"{infer_modulerun_path}/"),
        "data_path": URI(f"{data_path}/"),
    }

    shutil.rmtree(train_modulerun_path)
    shutil.rmtree(infer_modulerun_path)
    shutil.rmtree(data_path)


@pytest.mark.parametrize("train_config", testcases.classification)
def test_classification(setup: Dict[str, URI], train_config):
    train_modulerun_path = setup["train_modulerun_path"]
    infer_modulerun_path = setup["infer_modulerun_path"]
    data_path = setup["data_path"]

    model = ell.predictions.train(
        config=train_config,
        module_path=train_modulerun_path,
        data_path=data_path,
    )

    model_path = train_modulerun_path.folder("model")
    model_uri = model_path.file(f"model.pkl")
    preds_path = train_modulerun_path.folder("predictions")
    preds_uri = preds_path.file("predictions.parquet")
    scores_uri = train_modulerun_path.file("scores.json")
    scores_parquet_path = train_modulerun_path.folder("scores")
    scores_parquet_uri = scores_parquet_path.file("scores.parquet")
    etc_path = train_modulerun_path.folder("etc")
    plot_uris = (
        etc_path.file("test_cum_gain.png"),
        etc_path.file("test_lift.png"),
        etc_path.file("test_dist.png"),
    )

    # Check expected output files exist
    assert os.path.isfile(model_uri)
    assert os.path.isfile(preds_uri)
    assert os.path.isfile(scores_uri)
    assert os.path.isfile(scores_parquet_uri)
    if sys.platform != "darwin":
        for plot_uri in plot_uris:
            assert os.path.isfile(plot_uri)

    # Check that pickled model can be loaded with joblib
    with compat.env.fs.open(model_uri, "rb") as f:
        unpickled_model = joblib.load(f)
    assert type(unpickled_model) is type(model)

    # Check scores is not empty
    scores = compat.env.read_jsonish(scores_uri)
    assert isinstance(scores, dict)
    assert len(scores) > 0

    ell.predictions.infer(
        config={},
        module_path=infer_modulerun_path,
        model_uri=model_path,
        data_path=data_path,
    )
