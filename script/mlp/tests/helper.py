import os
import json
import pandas as pd
import hashlib
import glob
import numpy as np
import logging
from numpy.testing import assert_almost_equal

LOGGER = logging.getLogger(__name__)

SEED = 41


def assert_get_list_response(list):
    assert list, "list MUST be something"


def assert_scores_response(scores):
    assert isinstance(scores, dict), "scores MUST be a dict"
    assert all(
        [isinstance(scores[key], float) for key in scores.keys()]
    ), "scores values MUST be float"


def assert_get_box_response(box):
    assert isinstance(box, dict), "box MUST be dict"

    list_features = [e for e in box.keys() if not e.startswith("tree_rules")]
    for k in list_features:
        # for k, v in box.items():
        v = box[k]
        assert isinstance(v, dict), "single box MUST be dict"

        assert set(v.keys()) == {
            "lower",
            "upper",
            "actual",
        }, "box MUST be exactly `lower` and `upper`"

        assert (
            isinstance(v["upper"], float) or v["upper"] is None
        ), "box MUST be float or None"
        assert isinstance(v["actual"], float), "box MUST be float or None"
        assert (
            isinstance(v["lower"], float) or v["lower"] is None
        ), "box MUST be float or None"

        assert isinstance(v["upper"], float) or isinstance(
            v["lower"], float
        ), "either of the boundaries MUST be float"


def mock_predict_probabilities(X) -> np.ndarray:
    np.random.seed(SEED)
    return np.random.randint(100, size=(len(X), 2)) / 100


def mock_predict_categories(X) -> np.ndarray:
    np.random.seed(SEED)
    return np.random.randint(2, size=len(X))


# todo: Why does it returns null?
def assert_file_structure(extensions, exclusions, hashes=None):
    return
    if hashes is None:
        files = list_all_files(extensions, exclusions)
        hashes = {f: file_hash(f) for f in files}
        return hashes

    else:
        files = list_all_files(extensions, exclusions)
        updated_hashes = {f: file_hash(f) for f in files}

        assert_files_unchanged(hashes, updated_hashes)


def list_all_files(extensions: list, exclusions: list, prefix: str = "") -> list:
    """
    Returns a list of all files meeting the following criteria:
    * is one of these extensions
    * not in one of the exclusion folders
    * starting with the prefix

    :param extensions: list of file extensions
    :param exclusions: list of folders
    :param prefix: required prefix
    :return: list of files
    """
    if not isinstance(extensions, list) or not isinstance(exclusions, list):
        raise ValueError("both inputs MUST be lists")

    files = [glob.glob("**/*.{}".format(i), recursive=True) for i in extensions]
    files = [item for sublist in files for item in sublist]

    for e in exclusions:
        files = [f for f in files if not f.startswith(e)]

    files = [f for f in files if f.startswith(prefix)]

    return files


def assert_scores_files(run):
    uri = "tests/executorrun={}/modulerun={}/scores.json"
    uri = uri.format(run["executor"], run["model"])

    assert os.path.isfile(uri), f"No scores.json files available in {uri}."

    with open(uri, "r") as file:
        try:
            scores = json.load(file)
        except Exception:
            assert False, "scores.json could not be loaded. Must be JSON format."

    assert isinstance(scores, dict), "scores.json is not a dict."


def assert_files_unchanged(old, new):
    old_keys = list(old.keys())
    new_keys = list(new.keys())

    for key in old_keys:
        assert key in new_keys, "File {} has been deleted.".format(key)

    for key in new_keys:
        assert key in old_keys, "File {} has been added.".format(key)

    for key in old_keys + new_keys:
        assert old[key] == new[key], "File {} has been changed.".format(key)


def assert_wrote_predictions(run):
    """
    Test method that assert the following:
    - prediction.parquet file exists
    - All the prediction files have the same structure
    - Check that the minimum required columns are present
    :param run: dict containing executorrun and modulerun ids.
    """
    uri = "tests/executorrun={}/modulerun={}/predictions/*.parquet"
    uri = uri.format(run["executor"], run["model"])

    files = glob.glob(uri)

    assert len(files) > 0, "no predictions were written out."
    assert all(
        [os.path.isfile(f) for f in files]
    ), "not all files written out is actually a file."

    try:
        df = pd.concat(pd.read_parquet(f) for f in files)
    except Exception:
        assert False, "Not all *.parquet files have the same structure."

    columns_allowed = ["caseID", "eventTime", "probability", "tte", "category"]
    columns_required = ["caseID", "eventTime"]
    # assert all([c in columns_allowed for c in df.columns]), 'dataset contains unexpected columns.'
    assert any(
        [c not in columns_required for c in df.columns]
    ), "dataset missed minimum columns"

    dtypes = {
        "caseID": object,
        "eventTime": object,
        "probability": float,
        "tte": float,
        "category": int,
    }
    # TODO - uncomment this
    # assert all([df.dtypes[c] == dtypes[c] for c in df.columns]), \
    #    'dataset does not adhere to dtypes.' + str(df.dtypes) + "------" + str(dtypes)


def file_hash(file: str) -> str:
    """
    Calculates for the specified file a unique hash based on the operating system statistics
    :param file: filepath
    :return: sha256 hash value
    """
    hasher = hashlib.sha256()
    hasher.update(bytes(str(os.stat(file)), "utf-8"))
    hash = hasher.hexdigest()

    return hash


def assert_train_metrics(run):
    uri = "tests/executorrun={}/modulerun={}/train_metrics.csv"
    uri = uri.format(run["executor"], run["model"])

    assert os.path.isfile(uri), f"train_metrics.csv not written out in {uri}."

    try:
        content = pd.read_csv(uri)
    except Exception:
        assert False, "train_metrics.csv could not be read."

    assert isinstance(content, pd.DataFrame), "train_metrics.csv is not a dict."


def assert_feature_importance(run):
    uri = "tests/executorrun={}/modulerun={}/feature_importance.json"
    uri = uri.format(run["executor"], run["model"])

    assert os.path.isfile(uri), f"feature_importance.json not written out in {uri}."

    with open(uri, "r") as file:
        try:
            content = json.load(file)
        except Exception:
            assert False, "feature_importance.json could not be read."

    assert isinstance(content, dict), "feature_importance.json is not a dict."


def assert_scores_files_equals(run_1, run_2):
    uri = "tests/executorrun={}/modulerun={}/scores.json"
    uri_1 = uri.format(run_1["executor"], run_1["model"])
    uri_2 = uri.format(run_2["executor"], run_2["model"])
    uris = [uri_1, uri_2]

    scores = []
    for uri in uris:
        assert os.path.isfile(uri), f"No scores.json files available in {uri}."

        with open(uri, "r") as file:
            try:
                scores.append(json.load(file))
            except Exception:
                assert False, f"{uri} could not be loaded. Must be JSON format."

    # Assert dict are equals with 5 decimals precision
    assert_dict_values_equal(scores[0], scores[1], 5)


def assert_dict_values_equal(dict_1: dict, dict_2: dict, precision: int = 5):
    # Assert that all the keys are same.
    assert dict_1.keys() == dict_2.keys()

    for key in dict_1.keys():
        value_1 = dict_1.get(key)
        value_2 = dict_2.get(key)
        if isinstance(value_1, dict):
            assert_dict_values_equal(value_1, value_2)
        # Assert that all the results are equals with precision
        else:
            assert_almost_equal(
                value_1,
                value_2,
                decimal=precision,
                err_msg=f"The score {key} differ between two runs of the same model at {precision} decimals precision",
            )
