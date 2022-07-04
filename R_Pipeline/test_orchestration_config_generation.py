import unittest.mock
from pathlib import Path

import pytest
from ellib.config_tools import yaml

from ellib.tools.ds.config_generators.orchestration import (
    generate_orchestration_config_rte,
)

BEST_HPO_CONFIG_PATH = Path(__file__).parent.joinpath(
    "data", "hpo", "best_hpo_config.yml"
)

CONFIG_ROOT_RTE = Path(__file__).parent.joinpath(
    "data", "orchestration_config_generator_rte"
)
CONFIG_DIRS_RTE = [item for item in CONFIG_ROOT_RTE.iterdir() if item.is_dir()]

@unittest.mock.patch(
    "ellib.tools.ds.config_generators.prediction.read_prediction_configs"
)
@pytest.mark.parametrize(
    "config_dir_rte",
    CONFIG_DIRS_RTE,
    ids=[d.name for d in CONFIG_DIRS_RTE],
)
def test_orchestration_generator_rte(
    mock_read_prediction_configs,
    config_dir_rte,
):
    with open(config_dir_rte / "input.yml", "r") as f:
        input_config = yaml.load(f)
    with open(config_dir_rte / "expected.yml", "r") as f:
        expected_config = yaml.load(f)

    with open(BEST_HPO_CONFIG_PATH, "r") as f:
        best_hpo_config = yaml.load(f)

    mock_read_prediction_configs.return_value = {"reference-prediction-model-runid": best_hpo_config}

    output_config = generate_orchestration_config_rte(
        **input_config, client_name="democlient"
    )
    assert output_config == expected_config
