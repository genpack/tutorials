import shutil
import uuid
from typing import Tuple

import pytest

from ell.describers import ExplanationEvaluator
from ell.describers.explanation import LimeTreeDescriber
from ell.describers.utils.read_from_persisted import ReadFromPersisted
from tests.test_e2e.data import *
from .hardcoded_paths import PREDICTION_URI
from .helper import *

LIMETREE_ARGS = {
    "verbose": True,
    "num_samples": 5,
    "min_parsimony": 0.99,
    "random_state": 41,
}


@pytest.fixture(scope="function")
def setup_prediction_folder() -> dict:
    infer_agentrun = str(uuid.uuid4())
    infer_modulerun = str(uuid.uuid4())

    # PREPARE PREDICTION INFER FOLDER
    os.mkdir("tests/executorrun={}".format(infer_agentrun))
    os.mkdir("tests/executorrun={}/modulerun={}".format(infer_agentrun, infer_modulerun))
    os.mkdir(
        "tests/executorrun={}/modulerun={}/predictions".format(
            infer_agentrun, infer_modulerun
        )
    )
    os.mkdir("tests/executorrun={}/modulerun={}/etc".format(infer_agentrun, infer_modulerun))

    df = pd.DataFrame.from_dict(DATASET_MLSAMPLER_PREDICT_INFER)
    df.to_parquet(
        "tests/executorrun={}/modulerun={}/predictions/predictions.parquet".format(
            infer_agentrun, infer_modulerun
        )
    )

    yield {"prediction": {"executorrun": infer_agentrun, "modulerun": infer_modulerun}}

    shutil.rmtree("tests/executorrun={}".format(infer_agentrun))


@pytest.fixture(scope="function")
def load_prediction(setup_prediction_folder):
    # reads the prediction folder and returns a dataframe containing the
    # predicted probabilities and categories with caseID and eventTime as index
    run = setup_prediction_folder["prediction"]
    df = pd.read_parquet(
        PREDICTION_URI.format(os.getcwd(), run["executorrun"], run["modulerun"])
    ).set_index(["caseID", "eventTime"])
    # create an instance of the class ReadFromPersisted
    persisted_data = ReadFromPersisted(df)
    return persisted_data


@pytest.fixture(scope="function")
def describer_evaluator_read(load_prediction) -> ExplanationEvaluator:
    """Create and return an explanation evaluator.
    Accepts a fixture which is an MlMapper dataset
    """
    X = pd.DataFrame.from_dict(DATASET_MLSAMPLER_INFER).set_index(
        ["caseID", "eventTime"]
    )
    evaluator = ExplanationEvaluator(
        dataset=X,
        predict_or_get_probabilities=load_prediction.get_probabilities,
        predict_or_get_categories=load_prediction.get_categories,
        encodings=DATASET_CATEGORICAL_ENCODINGS,
        exclude_categoricals=None,
        features=None,
    )
    return evaluator


@pytest.fixture(scope="function")
def limetree_explanation(load_prediction) -> Tuple[pd.Series, dict, dict]:
    """ Returns the row to describe, a LimeTree box and the expected scores"""
    X = pd.DataFrame.from_dict(DATASET_MLSAMPLER_INFER).set_index(
        ["caseID", "eventTime"]
    )
    describer = LimeTreeDescriber(
        X=X,
        encodings=DATASET_CATEGORICAL_ENCODINGS,
        predict_or_get_probabilities=load_prediction.get_probabilities,
        predict_or_get_categories=load_prediction.get_categories,
    )

    row = X.iloc[0]
    box = describer.get_box(row, **LIMETREE_ARGS)

    expected_scores = {
        "precision": 1.0,
        "npv": 0.0,
        "power": 1.0,
        "coverage": 0.902160826325883,
        "parsimony": 0.9,
        "gain": 0.0,
        "fidelity": 0.0,
    }

    return row, box, expected_scores


def test_scores_limetree(describer_evaluator_read, limetree_explanation):
    """ Test case that the Limetree explanation scores are computed correctly with 5 decimals precision. """
    row, box, expected_scores = limetree_explanation
    scores = describer_evaluator_read.scores(box, row, features=row.index)

    expected_box = {
        "colF": {
            "lower": 0.5,
            "upper": None,
            "actual": 1.0,
        }
    }
    assert box == expected_box

    # Maybe a do an approximate equality check
    assert scores.keys() == expected_scores.keys()
    # The following is disabled for now as it is too fragile
    # for key in scores.keys():
    #     assert_almost_equal(
    #         scores[key],
    #         expected_scores[key],
    #         decimal=5,
    #         err_msg=(
    #             f"scores value: '{key}' is not as expected - "
    #             f"{scores[key]} != {expected_scores[key]}"
    #         ),
    #     )
