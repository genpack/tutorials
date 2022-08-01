import shutil
import uuid
from typing import Dict

import pandas as pd
import pytest
from ell.env.uri import URI

from ell.predictions import compat
from ell.predictions.feature_selection import genetic_feature_selector
from tests.test_e2e.data import (
    DATASET_CATEGORICAL_ENCODINGS,
    DATASET_MLSAMPLER_TEST,
    DATASET_MLSAMPLER_TRAIN,
)


@pytest.fixture()
def gss_setup(tmp_path_factory):
    executor_path = tmp_path_factory.mktemp(basename="gss.executorrun=", numbered=True)
    module_path = executor_path.joinpath("modulerun=main")
    module_path.mkdir(exist_ok=True, parents=True)
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

    # Prepare encodings file
    compat.env.write_jsonish(
        str(data_path.joinpath("categorical_encodings.json")),
        DATASET_CATEGORICAL_ENCODINGS,
    )

    yield {
        "executor_path": URI(f"{executor_path}/"),
        "module_path": URI(f"{module_path}/"),
        "data_path": URI(f"{data_path}/"),
    }

    shutil.rmtree(executor_path)
    shutil.rmtree(data_path)


def test_single_feature_single_experiment(mock_distributor_cls, gss_setup: Dict[str, URI]):
    executor_path = gss_setup["executor_path"]
    module_path = gss_setup["module_path"]
    data_path = gss_setup["data_path"]

    distributor = mock_distributor_cls(executor_path=executor_path, data_path=data_path)

    children = [
        {
            "batch_number": 1,
            "feature_set_id": 'FS0b1',
            "runid": str(uuid.uuid4()),
            "scores": {"gini_coefficient": 0.1, "lift_2": 7.1, "precision_2": 20.14},
            "feature_importances": {
                "colA": "1.0",
                "colD": "0.18",
                "colE": "0.21",
                "colG": "0.11",
            },
        },
        {
            "batch_number": 1,
            "feature_set_id": 'FS0b2',
            "runid": str(uuid.uuid4()),
            "scores": {"gini_coefficient": 0.2, "lift_2": 6.1, "precision_2": 19.20},
            "feature_importances": {
                "colA": "1.0",
                "colD": "0.18",
                "colF": "0.21",
                "colC": "0.0",
            },
        },
        {
            "batch_number": 2,
            "runid": str(uuid.uuid4()),
            "feature_set_id": 'FS0b2b1',
            "scores": {"gini_coefficient": 0.3, "lift_2": 8.1, "precision_2": 22.14},
            "feature_importances": {
                "colA": "1.0",
                "colD": "0.2",
                "colF": "0.1",
                "colE": "0.09",
                "colB": "0.01",
            },
        },
        {
            "batch_number": 2,
            "runid": str(uuid.uuid4()),
            "feature_set_id": 'FS0b2b2',
            "scores": {"gini_coefficient": 0.4, "lift_2": 8.6, "precision_2": 22.68},
            "feature_importances": {
                "colA": "1.0",
                "colD": "0.1",
                "colF": "0.1",
                "colG": "0.4",
                "colC": "0.00",
            },
        },
        {
            "batch_number": 3,
            "runid": str(uuid.uuid4()),
            "feature_set_id": 'FS0b2b2b1',
            "scores": {"gini_coefficient": 0.5, "lift_2": 9.1, "precision_2": 24.14},
            "feature_importances": {
                "colA": "1.0",
                "colD": "0.2",
                "colF": "0.1",
                "colG": "0.1",
                "colC": "0.1",
            },
        },
        {
            "batch_number": 3,
            "runid": str(uuid.uuid4()),
            "feature_set_id": 'FS0b2b2b2',
            "scores": {"gini_coefficient": 0.6, "lift_2": 12.0, "precision_2": 26.14},
            "feature_importances": {
                "colA": "1.0",
                "colD": "0.2",
                "colF": "0.05",
                "colG": "0.05",
                "colH": "0.3",
            },
        },
    ]
    feature_names = []
    importances = []
    gini_coefficients = []
    lift_2s = []
    precision_2s = []
    module_ids = []
    feature_set_ids = []
    batch_numbers = []
    for child in children:
        distributor.mock_modulerun(
            runid=child["runid"],
            scores=child["scores"],
            feature_importances=child["feature_importances"],
        )
        feature_names += list(child["feature_importances"].keys())
        importances += list(child["feature_importances"].values())
        gini_coefficients += [child["scores"]["gini_coefficient"]] * len(
            child["feature_importances"]
        )
        lift_2s += [child["scores"]["lift_2"]] * len(child["feature_importances"])
        precision_2s += [child["scores"]["precision_2"]] * len(
            child["feature_importances"]
        )
        module_ids += [child["runid"]] * len(child["feature_importances"])
        feature_set_ids += [child["feature_set_id"]] * len(child["feature_importances"])
        batch_numbers += [child["batch_number"]] * len(child["feature_importances"])

    config = {
        "feature_selection": {
            "num_batches": 3,
            "batch_size": 2,
            "subset_size": 0.2,
            "metric": "gini_coefficient",
            "initial_features": ["colA", "colD"],
            "sample_sets": ["2022-06-01"],
            "selection_mode": "robust",
        },
        "model": {
            "classifier": {
                "type": "XGBClassifier",
                "parameters": {},
            },
            "features": [
                "colA",
                "colB",
                "colC",
                "colD",
                "colE",
                "colF",
                "colG",
                "colH",
            ],
        },
    }
    feature_scores, output = genetic_feature_selector(config, distributor, module_path)
    output.index = list(range(output.shape[0]))
    #output = output.drop("feature_set_id", axis=1)

    expected_output = pd.DataFrame(
        {
            "feature_name": feature_names,
            "importance": importances,
            "module_id": module_ids,
            "batch_number": batch_numbers,
            "test_date": ["2022-06-01"] * len(feature_names),
            "feature_set_id": feature_set_ids,
            "gini_coefficient": gini_coefficients,
            "lift_2": lift_2s,
            "precision_2": precision_2s,
        }
    )
    expected_output.importance = expected_output.importance.astype("float64")
    expected_output = expected_output[output.columns]
    pd.testing.assert_frame_equal(output, expected_output)
    expected_feature_scores = {
        "colA": 0.6,
        "colB": 0.003,
        "colC": 0.05,
        "colD": 0.12,
        "colE": 0.027,
        "colF": 0.05,
        "colG": 0.16000000000000003,
        "colH": 0.18,
    }
    assert feature_scores == expected_feature_scores
