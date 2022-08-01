import logging
import os
import platform
import sys

import pkg_resources
from ell.env import ECSEnv, uri

from ell.predictions import (
    compat,
    infer,
    optimise_hyper_parameters,
    select_features,
    train,
    utils,
)

if isinstance(compat.env, ECSEnv):
    compat.env.setup_logging(
        log_uri=(
            uri.root("prediction", compat.WORKSPACE_NAME)
            .executor(compat.EXECUTORRUN)
            .model(compat.MODULERUN)
            .file("log.txt")
        )
    )
else:
    compat.env.setup_logging()
LOGGER = logging.getLogger("ell.predictions")


def main():
    """Entrypoint of the predictions container."""
    LOGGER.info("Start")
    LOGGER.debug("sys.argv", extra={"data": sys.argv})
    LOGGER.debug("os.environ", extra={"data": dict(os.environ)})
    LOGGER.debug("Platform: %s", platform.platform())
    installed_packages = pkg_resources.WorkingSet()
    LOGGER.debug(
        "Packages",
        extra={
            "data": {
                dist.project_name: dist.version
                for dist in sorted(
                    installed_packages, key=lambda dist: dist.project_name.lower()
                )
            }
        },
    )

    compat.env.update_meta(
        "STARTED",
        workspace_name=compat.WORKSPACE_NAME,
        component_name="prediction",
        run_id=compat.EXECUTORRUN,
        module_run=compat.MODULERUN,
    )
    try:
        config_uri = os.environ["config"]
        config = compat.env.read_jsonish(config_uri)
        LOGGER.debug("Config file loaded", extra={"data": config})
        start(config)
    except Exception as exc:
        LOGGER.exception("Fatal exception occurred: %s", exc)
        compat.env.update_meta(
            "FAILED",
            workspace_name=compat.WORKSPACE_NAME,
            component_name="prediction",
            run_id=compat.EXECUTORRUN,
            module_run=compat.MODULERUN,
        )
        LOGGER.info("FAILED")
    else:
        compat.env.update_meta(
            "SUCCEEDED",
            workspace_name=compat.WORKSPACE_NAME,
            component_name="prediction",
            run_id=compat.EXECUTORRUN,
            module_run=compat.MODULERUN,
        )
        LOGGER.info("SUCCEEDED")


def start(config: dict):
    """Run a job specified by a config."""
    executor_path = uri.root("prediction", compat.WORKSPACE_NAME).executor(compat.EXECUTORRUN)
    module_path = executor_path.model(compat.MODULERUN)
    data_path = utils.get_data_path(
        dataset_spec=config["dataset"],
        base_path=uri.root("sampled", compat.WORKSPACE_NAME),
    )

    if "feature_selection" in config.keys():
        LOGGER.debug("Mode is feature-selection")
        select_features(config, module_path, data_path)
    elif "hpo" in config.keys():
        LOGGER.debug("mode is hpo")
        optimise_hyper_parameters(config, executor_path, data_path)
    elif "mode" not in config:
        raise KeyError("mode is not defined.")
    elif config["mode"] == "train":
        LOGGER.debug("mode is train")
        train(config, module_path, data_path)
    elif config["mode"] == "infer":
        LOGGER.debug("mode is infer")
        model_uri = (
            uri.root("prediction", compat.WORKSPACE_NAME)
            .executor(config["model"]["executorrun"])
            .model(config["model"]["modulerun"])
            .folder("model")
        )
        infer(config, module_path, model_uri, data_path)
    else:
        raise ValueError(f"mode is unknown: {config['mode']}")


if __name__ == "__main__":
    main()
