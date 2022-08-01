import json
import logging
import os
import shutil
from glob import glob
from typing import Dict, Any

import pandas as pd
import pytest
import yaml
from ell.env.uri import URI

import ell.predictions
from ell.predictions import compat
from tests.test_e2e import testcases
from tests.test_e2e.data import *

logging.basicConfig(level=logging.DEBUG)
LOGGER = logging.getLogger(__name__)


@pytest.fixture(scope="function")
def hpo_setup(tmp_path_factory):
    executor_path = tmp_path_factory.mktemp(basename="hpo.executorrun=", numbered=True)
    data_path = tmp_path_factory.mktemp(basename="sampled.run=", numbered=True)

    # Prepare train data dir
    train_path = data_path.joinpath("train")
    train_path.mkdir(parents=True, exist_ok=True)
    df = pd.DataFrame.from_dict(DATASET_MLSAMPLER_TRAIN)
    for i in range(3):
        df.to_parquet(train_path.joinpath(f"data{i}.parquet"))

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

    # Prepare encodings file
    compat.env.write_jsonish(
        str(data_path.joinpath("categorical_encodings.json")),
        DATASET_CATEGORICAL_ENCODINGS,
    )

    yield {
        "executor_path": URI(f"{executor_path}/"),
        "data_path": URI(f"{data_path}/"),
    }

    shutil.rmtree(executor_path)
    shutil.rmtree(data_path)


@pytest.fixture()
def model_config() -> dict:
    config_xgb = """
        dataset: sampled
        mode: train
        optimise: true
        verbose: true
        max_memory_GB: 1
        model:
          classifier:
            type: XGBClassifier
            parameters:
              max_depth: 3
              n_estimators: 2
          transformer:
            type: Parallel
            steps:
              - type: Dummifier
                input:
                  include:
                    categoricals: true
              - type: UnitTransformer
                input:
                  remainder: true
          features:
            - colA
            - colB
            - colC
            - colD
            - colE
            - colF
        """
    return yaml.safe_load(config_xgb)


@pytest.mark.parametrize("hpo_config", testcases.hpo)
def test_hpo(
    hpo_setup: Dict[str, URI], model_config: Dict[str, Any], hpo_config: Dict[str, Any]
):
    executor_path = hpo_setup["executor_path"]
    data_path = hpo_setup["data_path"]
    model_config.update(hpo_config)

    ell.predictions.optimise_hyper_parameters(model_config, executor_path, data_path)

    hpo_results_uri = executor_path.file("hpo.json")
    assert os.path.isfile(hpo_results_uri)

    hpo_results = compat.env.read_jsonish(hpo_results_uri)
    assert isinstance(hpo_results, dict)

    assert isinstance(hpo_results["best_score"], float)
    assert isinstance(hpo_results["best_metrics"], dict)
    assert isinstance(hpo_results["best_parameters"], dict)
    assert isinstance(hpo_results["best_score"], float)
    best_moduleruns = hpo_results["best_moduleruns"]
    assert isinstance(best_moduleruns, list)
    assert all(isinstance(modulerun, str) for modulerun in best_moduleruns)
    best_modulerun_path = executor_path.model(best_moduleruns[0])

    num_trials = hpo_config["hpo"]["num_trials"]
    assert len(glob(executor_path.folder("modulerun=*"))) == num_trials

    results = pd.read_parquet(executor_path.file("trials.parquet"))
    assert len(results) == num_trials

    with open(executor_path.file("trials.json")) as f:
        trials = json.load(f)
    assert len(trials) == num_trials

    assert os.path.isfile(executor_path.folder("etc").file("searcher_state.pkl"))

    assert os.path.isdir(best_modulerun_path)
    assert os.path.isfile(best_modulerun_path.file("scores.json"))
