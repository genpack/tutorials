from ell.predictions.ensembling import AbstractAverager


def test_setting_seed():
    expected_seeds = [1, 2, 3]

    config = dict(
        type="AveragingEnsembler",
        parameters=dict(
            seed=expected_seeds,
            num_models=[3],
        ),
        models=[
            dict(
                classifier=dict(
                    type="XGBClassifier",
                    parameters=dict(
                        seed=0,
                    ),
                ),
            ),
        ],
    )

    ensembler = AbstractAverager.from_config(config)

    model_seeds = [
        cfg["classifier"]["parameters"]["seed"] for cfg in ensembler.model_cfgs
    ]
    assert model_seeds == expected_seeds
