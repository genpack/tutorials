import os
import random
import shutil
from typing import Dict

import pandas as pd
import pytest
from ell.env.uri import URI

import ell.describers
from ell.predictions import Model, compat, utils
from . import testcases
from .data import (
    DATASET_CATEGORICAL_ENCODINGS,
    DATASET_MLSAMPLER_INFER,
    DATASET_MLSAMPLER_TEST,
    DATASET_MLSAMPLER_TRAIN,
)

random.seed(42)


@pytest.fixture()
def setup(tmp_path_factory):
    run_path = tmp_path_factory.mktemp(basename="describers.run=", numbered=True)
    train_modulerun_path = tmp_path_factory.mktemp(
        basename="train.modulerun=", numbered=True
    )
    infer_modulerun_path = tmp_path_factory.mktemp(
        basename="infer.modulerun=", numbered=True
    )
    data_path = tmp_path_factory.mktemp(basename="sampled.run=", numbered=True)

    infer_dataset = pd.DataFrame.from_dict(DATASET_MLSAMPLER_INFER)

    # Prepare rows to describe
    rows_uri = run_path.joinpath(
        "rows_to_describe", "attempt=00", "part-00000.snappy.parquet"
    )
    rows_to_describe = infer_dataset
    os.makedirs(rows_uri.parent, exist_ok=True)
    rows_to_describe.to_parquet(rows_uri)

    # Prepare train modulerun dir
    model = Model.from_config(
        config=dict(
            classifier=dict(
                type="XGBClassifier",
                # Parameters are set so the model is trained very quickly
                parameters=dict(max_depth=1, n_estimators=1, seed=42),
            )
        )
    )
    train_dataset = (
        pd.DataFrame(DATASET_MLSAMPLER_TRAIN)
        .sample(1000, random_state=42)
        .set_index(["caseID", "eventTime"])
    )
    model.fit(train_dataset)
    model.save(str(train_modulerun_path))
    model_uri = train_modulerun_path.joinpath("model", "model.pkl")

    # Prepare infer modulerun dir
    preds_uri = infer_modulerun_path.joinpath("predictions", "predictions.parquet")
    proba_df, cats_df = model.predict(infer_dataset.set_index(["caseID", "eventTime"]))
    utils.persist_predictions(str(preds_uri), proba_df, cats_df)

    # Prepare infer data dir
    infer_path = data_path.joinpath("infer")
    infer_path.mkdir(parents=True, exist_ok=True)
    infer_dataset.to_parquet(infer_path.joinpath("data.parquet"))

    # Prepare test data dir
    test_path = data_path.joinpath("test")
    test_path.mkdir(parents=True, exist_ok=True)
    test_dataset = pd.DataFrame(DATASET_MLSAMPLER_TEST)
    test_dataset.to_parquet(test_path.joinpath("data.parquet"))

    # Prepare encodings file
    compat.env.write_jsonish(
        str(data_path.joinpath("categorical_encodings.json")),
        DATASET_CATEGORICAL_ENCODINGS,
    )

    yield {
        "run_path": URI(f"{run_path}/"),
        "rows_uri": URI(str(rows_uri)),
        "module_path": URI(f"{infer_modulerun_path}/"),
        "model_uri": URI(str(model_uri)),
        "data_path": URI(f"{data_path}/"),
    }

    shutil.rmtree(run_path)
    shutil.rmtree(train_modulerun_path)
    shutil.rmtree(infer_modulerun_path)
    shutil.rmtree(data_path)


@pytest.mark.parametrize("describer_config", testcases.explanation)
def test_explanation(setup: Dict[str, URI], describer_config: dict):
    run_path = setup["run_path"]
    rows_uri = setup["rows_uri"]
    module_path = setup["module_path"]
    model_uri = setup["model_uri"]
    data_path = setup["data_path"]

    num_rows_to_describe = pd.read_parquet(rows_uri).shape[0]

    ell.describers.api.describe(
        config=describer_config,
        run_path=run_path,
        attempt_number=0,
        partition_id=0,
        rows_uri=rows_uri,
        module_path=module_path,
        data_path=data_path,
        model_uri=model_uri,
    )

    explanations_path = run_path.folder("explanations")
    explanations_uri = explanations_path.folder("attempt=00").file(
        "part-00000.snappy.parquet"
    )
    scores_path = run_path.folder("scores")
    scores_uri = scores_path.folder("attempt=00").file("part-00000.snappy.parquet")
    englishing_path = run_path.folder("englishing")
    englishing_uri = englishing_path.folder("attempt=00").file(
        "part-00000.snappy.parquet"
    )

    # Check expected output files exist
    assert os.path.isfile(explanations_uri)
    assert os.path.isfile(scores_uri)
    assert os.path.isfile(englishing_uri)

    # Check number of caseID/eventTimes in each file is what we expect
    df_explanations = pd.read_parquet(explanations_uri)
    assert (
        df_explanations[["caseID", "eventTime"]].drop_duplicates().shape[0]
        == num_rows_to_describe
    )
    df_scores = pd.read_parquet(scores_uri)
    assert (
        df_scores[["caseID", "eventTime"]].drop_duplicates().shape[0]
        == num_rows_to_describe
    )
    if describer_config.get("reason_map") or describer_config.get("manual_context"):
        # Only check if englishing exists if the config will actually
        # generate it
        df_englishing = pd.read_parquet(englishing_uri)
        assert (
            df_englishing[["caseID", "eventTime"]].drop_duplicates().shape[0]
            == num_rows_to_describe
        )
