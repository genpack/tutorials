from datetime import timedelta

import pytest
from ray import tune

from ell.predictions.hpo import Bayesian, CmaEs
from ell.predictions.hpo.ray_hpo.ray_hpo_abc import (
    RayAbstractTuner,
)
from ell.predictions.hpo.ray_hpo.stoppers import (
    DurationStopper,
    PlateauStopper,
    OrStopper,
)
from ell.predictions.hpo.utils import Trial

SPACE_SPEC = dict(
    randint=dict(
        distribution="randint",
        range=[5, 50],
        step=5,
    ),
    randint_stepless=dict(
        distribution="randint",
        range=[5, 50],
    ),
    lograndint=dict(
        distribution="lograndint",
        range=[7, 700],
        step=7,
        base=7,
    ),
    lograndint_stepless=dict(
        distribution="lograndint",
        range=[7, 700],
    ),
    uniform=dict(
        distribution="uniform",
        range=[2.63, 9.21],
        step=0.01,
    ),
    uniform_stepless=dict(
        distribution="uniform",
        range=[2.63, 9.21],
    ),
    loguniform=dict(
        distribution="loguniform",
        range=[2.63, 9.21],
        step=0.01,
        base=0.5,
    ),
    loguniform_stepless=dict(
        distribution="loguniform",
        range=[2.63, 9.21],
    ),
    normal=dict(
        distribution="normal",
        mean=10,
        std=5,
        floor=0,
    ),
    choice=dict(
        distribution="choice",
        choices=["a", "b", "c"],
    ),
)


def distribution_eq(d1, d2):
    """Utility method to compare Ray Distributions/Domains"""
    if not type(d1) is type(d2):
        return False

    d1_dict = d1.__dict__
    d2_dict = d2.__dict__
    if d1_dict.keys() != d2_dict.keys():
        return False

    for key in d1_dict.keys():
        val1 = d1_dict[key]
        val2 = d2_dict[key]

        if isinstance(val1, (tune.sample.Sampler, tune.sample.Domain)):
            if not distribution_eq(val1, val2):
                return False
        else:
            if val1 != val2:
                return False

    return True


def test_setup():
    """Test the RayABC specific init behaviour."""
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

    hpo = RayAbstractTuner.from_config(config)
    assert isinstance(hpo._stopper, OrStopper)
    assert len(hpo._stopper._stoppers) == 1
    assert isinstance(hpo._stopper._stoppers[0], DurationStopper)
    assert (
        hpo._stopper._stoppers[0]._timeout_seconds == timedelta(days=2).total_seconds()
    )

    # Check that additional early stopping is respected
    config["hpo"]["early_stopping"] = dict(
        patience=5,
        num_top_models=3,
    )
    hpo: RayAbstractTuner = RayAbstractTuner.from_config(
        config
    )
    assert isinstance(hpo._stopper, OrStopper)
    stoppers = hpo._stopper._stoppers
    assert len(stoppers) == 2
    assert any(isinstance(stopper, PlateauStopper) for stopper in stoppers)


def test_abc_configure_search_space():
    space_spec = SPACE_SPEC.copy()
    space, interpretation_args = RayAbstractTuner._configure_search_space(
        space_spec
    )

    expected_space = dict(
        randint=tune.qrandint(5, 50, q=5),
        randint_stepless=tune.randint(5, 51),
        lograndint=tune.qlograndint(7, 700, q=7, base=7),
        lograndint_stepless=tune.lograndint(7, 700),
        uniform=tune.quniform(2.63, 9.21, q=0.01),
        uniform_stepless=tune.uniform(2.63, 9.21),
        loguniform=tune.qloguniform(2.63, 9.21, q=0.01, base=0.5),
        loguniform_stepless=tune.loguniform(2.63, 9.21),
        normal=tune.randn(10, 5),
        choice=tune.choice(["a", "b", "c"]),
    )
    expected_interpretation_args = dict(normal_limits=dict(normal=(0, None)))

    assert space.keys() == expected_space.keys()
    for key in space.keys():
        assert distribution_eq(space[key], expected_space[key])

    assert interpretation_args == expected_interpretation_args


def test_bayes_configure_search_space():
    space_spec = SPACE_SPEC.copy()
    with pytest.raises(ValueError):
        Bayesian._configure_search_space(space_spec)

    # Remove unsupported distributions
    del space_spec["lograndint"]
    del space_spec["lograndint_stepless"]
    del space_spec["loguniform"]
    del space_spec["loguniform_stepless"]
    del space_spec["normal"]

    space, interpretation_args = Bayesian._configure_search_space(space_spec)

    expected_space = dict(
        randint=tune.uniform(5, 50),
        randint_stepless=tune.uniform(5, 50),
        uniform=tune.uniform(2.63, 9.21),
        uniform_stepless=tune.uniform(2.63, 9.21),
        choice=tune.uniform(0, 2),
    )
    expected_interpretation_args = dict(
        choice_map=dict(choice={0: "a", 1: "b", 2: "c"}),
        step_map=dict(randint=5, randint_stepless=1, uniform=0.01),
    )

    assert space.keys() == expected_space.keys()
    for key in space.keys():
        assert distribution_eq(space[key], expected_space[key])

    assert interpretation_args == expected_interpretation_args


def test_cma_configure_search_space():
    space_spec = SPACE_SPEC.copy()

    with pytest.raises(ValueError):
        CmaEs._configure_search_space(space_spec)

    # Remove unsupported distributions
    del space_spec["normal"]
    space, interpretation_args = CmaEs._configure_search_space(space_spec)

    expected_space = dict(
        randint=tune.qrandint(5, 50, q=5),
        randint_stepless=tune.randint(5, 51),
        lograndint=tune.qlograndint(7, 700, q=7, base=7),
        lograndint_stepless=tune.lograndint(7, 700),
        uniform=tune.quniform(2.63, 9.21, q=0.01),
        uniform_stepless=tune.uniform(2.63, 9.21),
        loguniform=tune.qloguniform(2.63, 9.21, q=0.01, base=0.5),
        loguniform_stepless=tune.loguniform(2.63, 9.21),
        choice=tune.choice(["a", "b", "c"]),
    )
    expected_interpretation_args = dict(normal_limits=dict())

    assert space.keys() == expected_space.keys()
    for key in space.keys():
        assert distribution_eq(space[key], expected_space[key])

    assert interpretation_args == expected_interpretation_args


def test_bayesian_parameter_interpretation():
    params = dict(
        eta_k=25.123,
        n_estimators=47.9943,
        num_features=52.545,
        categorical=0.12345,
        gamma=0.1234,
    )
    interpretation_args = dict(
        choice_map=dict(categorical={0: "a", 1: "b"}),
        step_map=dict(eta_k=1, n_estimators=5, num_features=3, gamma=0.01),
    )
    expected_params = dict(
        eta=0.5, n_estimators=50, num_features=54, categorical="a", gamma=0.12
    )

    interpreted_params = Bayesian._interpret_parameters(params, **interpretation_args)

    assert interpreted_params == expected_params


def test_early_stopper():
    # Simulate a test that increases for 10 trials then plateaus
    results = list(range(10)) + [-1] * 50
    trials = []
    for i, result in enumerate(results):
        trials.append(Trial(trial_id=i, parameters={}, results=dict(f_1=result)))

    # Basic use case, with only 1 top model
    stopper = PlateauStopper(
        metric="f_1", maximise=True, patience=5, num_top_models=1, delay=0
    )
    for trial_no, trial in enumerate(trials, start=1):
        if stopper.should_stop_experiment(trial):
            # 16: Top model is achieved in iteration 10, then 5 patience.
            assert trial_no == 15
            break

    # Test with more top models
    stopper = PlateauStopper(
        metric="f_1", maximise=True, patience=4, num_top_models=5, delay=0
    )
    for trial_no, trial in enumerate(trials, start=1):
        if stopper.should_stop_experiment(trial):
            # 19: Top 5 models are saturated at iteration 10, then 4 patience.
            assert trial_no == 14
            break

    # Test with delay
    stopper = PlateauStopper(
        metric="f_1", maximise=True, patience=5, num_top_models=5, delay=20
    )
    for trial_no, trial in enumerate(trials, start=1):
        if stopper.should_stop_experiment(trial):
            # 25: Top 5 models are saturated at iteration 10, but we delay until
            # iteration 20, then 5 patience.
            assert trial_no == 25
            break
