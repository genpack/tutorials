import pandas as pd

from ell.predictions.classification import (
    AbstractClassifier,
    AbstractPandasClassifier,
    XGBClassifier,
)
from tests.test_e2e.data import DATASET_MLSAMPLER_TEST, DATASET_MLSAMPLER_TRAIN


def test_classifier_creation():
    classifier = XGBClassifier(config={})
    expected_params = {}
    expected_params.update(AbstractClassifier.DEFAULT_PARAMETERS)
    expected_params.update(AbstractPandasClassifier.DEFAULT_PARAMETERS)
    expected_params.update(XGBClassifier.DEFAULT_PARAMETERS)
    assert classifier.parameters == expected_params

    classifier = XGBClassifier(
        config={"parameters": {"max_depth": 100}},
    )
    expected_params["max_depth"] = 100
    assert classifier.parameters == expected_params


def test_decision_boundary():
    classifier = XGBClassifier(
        config=dict(parameters=dict(max_depth=5, n_estimators=10))
    )
    classifier.cutpoint = 0.94

    df_train = pd.DataFrame(DATASET_MLSAMPLER_TRAIN).set_index(["caseID", "eventTime"])
    classifier.fit(df_train)

    df_test = pd.DataFrame(DATASET_MLSAMPLER_TEST).set_index(["caseID", "eventTime"])
    proba_df, cats_df = classifier.predict(df_test)
    pos_proba = proba_df.iloc[:, 1]
    category = cats_df["category"]
    assert not category[pos_proba < classifier.cutpoint].eq(1).any()


def test_reproducibility():
    df_train = pd.DataFrame(DATASET_MLSAMPLER_TRAIN).set_index(["caseID", "eventTime"])
    df_test = pd.DataFrame(DATASET_MLSAMPLER_TEST).set_index(["caseID", "eventTime"])
    results = []
    for _ in range(2):
        classifier = XGBClassifier(
            config=dict(parameters=dict(seed=42, max_depth=5, n_estimators=10))
        )
        classifier.fit(df_train)
        scores = classifier.score(df_test)

        results.append(scores)

    assert results[0] == results[1]

    # Change the seed to ensure it actually has an effect
    classifier = XGBClassifier(
        config=dict(parameters=dict(seed=43, max_depth=5, n_estimators=10))
    )
    classifier.fit(df_train)
    scores = classifier.score(df_test)

    assert scores != results[0]


def test_custom_target(dataset_sampled_train, dataset_sampled_test):
    classifier = XGBClassifier(
        config=dict(
            target="label2", parameters=dict(seed=42, n_estimators=1, max_depth=1)
        )
    )

    dataset_sampled_train = dataset_sampled_train.rename(
        columns={"label": "label2"}
    )
    dataset_sampled_test = dataset_sampled_test.rename(columns={"label": "label2"})

    classifier.fit(dataset_sampled_train)
    proba_df, cats_df = classifier.predict(dataset_sampled_test, return_labels=True)

    assert "label" in cats_df.columns
    pd.testing.assert_series_equal(
        cats_df["label"], dataset_sampled_test["label2"], check_names=False
    )
