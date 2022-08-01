from ell.predictions.classification import Scores
from ell.predictions.hpo.utils import (
    set_config_value,
    aggregate_trial_scores,
    configure_model_config,
)


def test_set_config_value():
    config = dict(
        dataset="1234",
        model=dict(
            classifier=dict(
                type="XGBClassifier",
                parameters=dict(alpha=0.2, beta=0.2, gamma=0.3),
            )
        ),
    )

    # Test simple scalar set
    output_config = set_config_value(config, "alpha", 3)
    assert output_config["model"]["classifier"]["parameters"]["alpha"] == 3

    # Test object set new key
    output_config = set_config_value(config, "x1.nested", dict(x1=2, x2=3))
    assert output_config["model"]["classifier"]["parameters"]["x1"]["nested"] == dict(
        x1=2, x2=3
    )

    # Test absolute path
    new_params = dict(alpha=1, beta=2, gamma=3)
    output_config = set_config_value(
        config, "$.model.classifier.parameters", new_params
    )
    assert output_config["model"]["classifier"]["parameters"] == new_params


def test_aggregate_trial_scores():
    s1 = Scores(
        accuracy=0,
        f_1=0,
        precision=0,
        recall=0,
        log_loss=0,
        churn_rate=0,
        confusion_matrix={},
        lift_1=0,
        lift_2=0,
        lift_5=0,
        lift_10=0,
        lift_20=0,
        lift_churn_rate=0,
        precision_1=0,
        precision_2=0,
        precision_5=0,
        precision_10=0,
        precision_20=0,
        gini_coefficient=0,
    ).to_dict()
    s2 = Scores(
        accuracy=1,
        f_1=1,
        precision=1,
        recall=1,
        log_loss=1,
        churn_rate=1,
        confusion_matrix={},
        lift_1=1,
        lift_2=1,
        lift_5=1,
        lift_10=1,
        lift_20=1,
        lift_churn_rate=1,
        precision_1=1,
        precision_2=1,
        precision_5=1,
        precision_10=1,
        precision_20=1,
        gini_coefficient=1,
    ).to_dict()
    s3 = Scores(
        accuracy=2,
        f_1=2,
        precision=2,
        recall=2,
        log_loss=2,
        churn_rate=2,
        confusion_matrix={},
        lift_1=2,
        lift_2=2,
        lift_5=2,
        lift_10=2,
        lift_20=2,
        lift_churn_rate=2,
        precision_1=2,
        precision_2=2,
        precision_5=2,
        precision_10=2,
        precision_20=2,
        gini_coefficient=2,
    ).to_dict()

    s1.pop("confusion_matrix")
    s2.pop("confusion_matrix")
    s3.pop("confusion_matrix")

    assert aggregate_trial_scores({"s1": s1, "s2": s2, "s3": s3}, "max") == s3
    assert aggregate_trial_scores({"s1": s1, "s2": s2, "s3": s3}, "min") == s1
    assert aggregate_trial_scores({"s1": s1, "s2": s2, "s3": s3}, "mean") == s2
    assert aggregate_trial_scores({"s1": s1, "s2": s2, "s3": s3}, "median") == s2


def test_configure_model_config():
    config = dict(
        dataset="1234",
        model=dict(
            classifier=dict(
                type="XGBClassifier",
                parameters=dict(alpha=0.2, beta=0.2, gamma=0.3),
            ),
            features=["A", "B", "C", "D", "E"],
        ),
    )
    parameters = dict(num_features=3, num_estimators=100, alpha=3)

    expected_config = dict(
        dataset="1234",
        model=dict(
            classifier=dict(
                type="XGBClassifier",
                parameters=dict(alpha=3, beta=0.2, gamma=0.3, num_estimators=100),
            ),
            features=["A", "B", "C"],
        ),
    )

    assert configure_model_config(config, parameters) == expected_config

    # Test JSONPath
    parameters["$.model.classifier.type"] = "LogisticRegressionClassifier"
    expected_config["model"]["classifier"]["type"] = "LogisticRegressionClassifier"
    assert configure_model_config(config, parameters) == expected_config
