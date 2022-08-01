from datetime import timedelta
from unittest.mock import MagicMock, patch

import pytest

from ell.predictions.hpo import (
    AbstractTuner,
    TreeOfParzen,
    Bayesian,
    CmaEs,
)
from ell.predictions.hpo.utils import Trial


def test_from_config():
    config = dict(
        dataset="12345",
        hpo=dict(
            algorithm="TreeOfParzen",
            space=dict(param1=dict(distribution="uniform", range=[0, 10])),
            duration="2d",
        ),
        model=dict(
            classifier=dict(
                type="XGBClassifier",
            ),
            features=["A", "B", "C"],
        ),
    )
    hpo = AbstractTuner.from_config(config)

    assert isinstance(hpo, TreeOfParzen)
    assert hpo._metric == "gini_coefficient"
    assert hpo._maximise
    assert hpo._sample_sets == []
    assert hpo._trial_aggregator == "mean"
    assert hpo._duration == timedelta(days=2)
    assert hpo._num_trials == TreeOfParzen.DEFAULT_NUM_TRIALS
    assert hpo._num_parallel == TreeOfParzen.DEFAULT_NUM_PARALLEL

    config["hpo"]["algorithm"] = "Bayesian"
    hpo = AbstractTuner.from_config(config)
    assert isinstance(hpo, Bayesian)

    config["hpo"]["algorithm"] = "CmaEs"
    hpo = AbstractTuner.from_config(config)
    assert isinstance(hpo, CmaEs)

    config["hpo"]["algorithm"] = "INVALID_CLASS"
    with pytest.raises(ValueError):
        AbstractTuner.from_config(config)

    with pytest.raises(ValueError):
        config["hpo"]["space"] = dict()
        AbstractTuner.from_config(config)


def test_configure_num_features():
    feats = ["feature"] * 10

    feature_spec = AbstractTuner._configure_num_features_spec(feats, True)
    assert feature_spec == dict(distribution="randint", range=[1, 10])

    feature_spec = AbstractTuner._configure_num_features_spec(
        feats, {"min_features": 5}
    )
    assert feature_spec == dict(distribution="randint", range=[5, 10])

    feature_spec = AbstractTuner._configure_num_features_spec(
        feats, {"max_features": 5}
    )
    assert feature_spec == dict(distribution="randint", range=[1, 5])

    feature_spec = AbstractTuner._configure_num_features_spec(
        feats, {"min_features": 5, "max_features": 8}
    )
    assert feature_spec == dict(distribution="randint", range=[5, 8])

    with pytest.raises(ValueError):
        AbstractTuner._configure_num_features_spec(
            feats, {"min_features": 7, "max_features": 5}
        )


def test_parameter_interpretation():
    params = dict(eta_k=25, n_estimators=50, scale_pos_weight=-0.123)

    interpreted_params = AbstractTuner._interpret_parameters(params)
    assert interpreted_params == dict(eta=0.5, n_estimators=50, scale_pos_weight=-0.123)

    interpreted_params = AbstractTuner._interpret_parameters(
        params,
        normal_limits=dict(
            scale_pos_weight=(0, None),
        ),
    )
    assert interpreted_params == dict(eta=0.5, n_estimators=50, scale_pos_weight=0)

    params.update(scale_pos_weight=1.5)
    interpreted_params = AbstractTuner._interpret_parameters(
        params,
        normal_limits=dict(
            scale_pos_weight=(0, 1),
        ),
    )
    assert interpreted_params == dict(eta=0.5, n_estimators=50, scale_pos_weight=1)


@patch("ell.predictions.distributing.LocalDistributor")
def test_compute_single_trial(MockDistributor):
    distributor = MockDistributor()
    distributor.distribute = MagicMock(return_value="runid")
    distributor.collect_scores = MagicMock(return_value=dict(runid=dict(gini_coefficient=5)))
    config = dict(key1="val1", key2="val2")

    trial = Trial(trial_id=0, parameters={})
    output_trial = AbstractTuner._compute_single_trial(
        trial, config, distributor
    )
    distributor.distribute.assert_called_once_with(config)

    assert output_trial.results == dict(gini_coefficient=5)
    assert output_trial.moduleruns == ["runid"]


@patch("ell.predictions.distributing.LocalDistributor")
def test_compute_multiple_trials(MockDistributor):
    distributor = MockDistributor()

    model_scores = dict(
        model1=dict(gini_coefficient=3.0),
        model2=dict(gini_coefficient=7.0),
        model3=dict(gini_coefficient=17.0),
    )

    distributor.distribute = MagicMock(return_value="run")
    distributor.collect_scores = MagicMock(return_value=model_scores)

    trial = Trial(trial_id=0, parameters={})
    output_trial = AbstractTuner._compute_multi_sample_trial(
        trial, {}, distributor, ["a", "b", "c"], "min"
    )
    assert output_trial.results == dict(gini_coefficient=3.0)
    assert output_trial.moduleruns == ["run", "run", "run"]

    trial = Trial(trial_id=0, parameters={})
    output_trial = AbstractTuner._compute_multi_sample_trial(
        trial, {}, distributor, ["a", "b", "c"], "median"
    )
    assert output_trial.results == dict(gini_coefficient=7.0)
    assert output_trial.moduleruns == ["run", "run", "run"]

    trial = Trial(trial_id=0, parameters={})
    output_trial = AbstractTuner._compute_multi_sample_trial(
        trial, {}, distributor, ["a", "b", "c"], "mean"
    )
    assert output_trial.results == dict(gini_coefficient=9.0)
    assert output_trial.moduleruns == ["run", "run", "run"]

    trial = Trial(trial_id=0, parameters={})
    output_trial = AbstractTuner._compute_multi_sample_trial(
        trial, {}, distributor, ["a", "b", "c"], "max"
    )
    assert output_trial.results == dict(gini_coefficient=17.0)
    assert output_trial.moduleruns == ["run", "run", "run"]
