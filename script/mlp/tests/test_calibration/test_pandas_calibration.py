import pandas as pd
import numpy as np

SEED = 42
from ell.predictions.calibration.pandas.min_max_calibrator import MinMaxCalibrator
from ell.predictions.classification import XGBClassifier
from tests.test_e2e.data import (
    DATASET_MLSAMPLER_TEST,
    DATASET_MLSAMPLER_TRAIN,
    DATASET_MLSAMPLER_OPTIMISE,
)


def _generate_probabilities_df(rows=1000, seed=SEED):
    """
    Helper function to simulate generated probabilities by model
    @param rows: number of observations to simulate
    @param seed: Seed
    @return: Dataframe with multiindex (CaseID, eventTime) and 2 class probabilities.
    """
    np.random.seed(seed)
    import random
    import string
    import datetime

    index = pd.MultiIndex.from_frame(
        pd.DataFrame(
            [
                {
                    "caseID": "".join(
                        random.choices(string.ascii_uppercase + string.digits, k=5)
                    ),
                    "eventTime": datetime.date(2020, 1, 1)
                    + datetime.timedelta(days=random.randint(0, 1000)),
                }
                for i in range(rows)
            ]
        )
    )

    probas = pd.DataFrame(np.random.randint(101, size=(rows, 1)) / 100, index=index)
    probas[1] = 1 - probas[0]
    return probas


def test_calibration_probabilities():
    """
    Test e2e xgboost classifier with MinMax calibration
    """

    classifier = XGBClassifier(
        config=dict(
            parameters=dict(max_depth=5, n_estimators=10),
            calibrator=dict(type="MinMaxCalibrator"),
        )
    )
    classifier.cutpoint = 0.94

    df_train = pd.DataFrame(DATASET_MLSAMPLER_TRAIN).set_index(["caseID", "eventTime"])
    classifier.fit(df_train)

    df_test = pd.DataFrame(DATASET_MLSAMPLER_TEST).set_index(["caseID", "eventTime"])
    proba_df, cats_df = classifier.predict(df_test)
    sum = proba_df[0] + proba_df[1]
    assert min(sum) == 1
    assert max(sum) == 1

    df_test = pd.DataFrame(DATASET_MLSAMPLER_OPTIMISE).set_index(
        ["caseID", "eventTime"]
    )
    proba_df, cats_df = classifier.predict(df_test)
    sum = proba_df[0] + proba_df[1]
    assert min(sum) == 1
    assert max(sum) == 1


def test_calibrator_min_max():
    """
    Test calibrator MinMax
    """
    calibrator = MinMaxCalibrator({"type": "MinMaxCalibrator"})
    probas_train = _generate_probabilities_df(5)
    probas_infer = _generate_probabilities_df(100)
    calibrator.fit(probas_train)
    train_calib = calibrator.transform(probas_train.copy())
    result = calibrator.transform(probas_infer.copy())
    sum = result[0] + result[1]
    assert min(sum) == 1
    assert max(sum) == 1

    # Calibration is isotonic. (Edge case id both values are identical
    pd.testing.assert_index_equal(
        probas_train.sort_values(by=0).index, train_calib.sort_values(by=0).index
    )


def test_calibrator_case1():
    """
    Train dataset taking values between 0 and 1.
    infer dataset with only two rows
    assert the probabilities are the same if apply scaling and not applying scaling
    """
    calibrator = MinMaxCalibrator({"type": "MinMaxCalibrator"})
    probas_train = _generate_probabilities_df(10000)
    probas_infer = _generate_probabilities_df(2)
    calibrator.fit(probas_train.copy())
    infer_calib = calibrator.transform(probas_infer.copy())
    pd.testing.assert_frame_equal(infer_calib, probas_infer)


def test_calibrator_case2():
    """
    train dataset not taking values between 0 and 1.
    infer dataset with two rows
    assert we apply the transformation to the rows.
    """
    calibrator = MinMaxCalibrator({"type": "MinMaxCalibrator"})
    probas_train = _generate_probabilities_df(5)
    probas_infer = _generate_probabilities_df(2)
    calibrator.fit(probas_train.copy())
    infer_calib = calibrator.transform(probas_infer.copy())
    # little trick to assert frames ar not equal.
    try:
        pd.testing.assert_frame_equal(infer_calib, probas_infer)
    except AssertionError:
        # frames are not equal
        pass
    else:
        # frames are equal
        raise AssertionError


def test_calibrator_case3():
    """
    train dataset not taking values between 0 and 1 [0.1,0.99]
    infer dataset with bigger range train train.
    make sure we clip the ends to 0 and 1.
    assert values are between 0 and 1.
    """
    calibrator = MinMaxCalibrator({"type": "MinMaxCalibrator"})
    probas_train = _generate_probabilities_df(5)
    probas_infer = _generate_probabilities_df(1000)
    calibrator.fit(probas_train.copy())
    infer_calib = calibrator.transform(probas_infer.copy())
    assert max(infer_calib[0]) <= 1
    assert min(infer_calib[0]) >= 0
