import json
import logging
import os
import platform
import sys
from datetime import datetime

import pkg_resources
from ell.env import ECSEnv, uri

from ell.describers import compat, describe, utils

if isinstance(compat.env, ECSEnv):
    compat.env.setup_logging(
        log_uri=(
            uri.root("describer", compat.WORKSPACE_NAME)
            .run(compat.RUN)
            .folder("container_logs")
            .folder(f"attempt={compat.ATTEMPT_NUMBER:02}")
            .file(f"partition-{compat.PARTITION_ID:05}.txt")
        )
    )
else:
    compat.env.setup_logging()

LOGGER = logging.getLogger("ell.describers")


def main():
    """Entrypoint of the describer container."""
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
    LOGGER.debug("Run ID: %s", compat.RUN)
    LOGGER.debug("Attempt number: %s", compat.ATTEMPT_NUMBER)
    LOGGER.debug("Partition ID: %s", compat.PARTITION_ID)

    utils.update_container_meta(state="STARTED", start_time=datetime.utcnow())

    try:
        start()
    except Exception as exc:
        LOGGER.exception("Fatal exception: %s", exc, exc_info=exc)

        utils.update_container_meta(
            state="FAILED",
            end_time=datetime.utcnow(),
        )
    else:
        utils.update_container_meta(
            state="SUCCEEDED",
            end_time=datetime.utcnow(),
        )


def start():
    run_path = uri.root("describer", compat.WORKSPACE_NAME).run(compat.RUN)

    LOGGER.info("Reading config file")
    config = compat.env.read_jsonish(run_path.file("config.json"))

    rows_uri = run_path.folder("rows_to_describe").folder(
        f"attempt={compat.ATTEMPT_NUMBER:02}"
    )
    glob_result = compat.env.fs.glob(
        rows_uri.file(f"part-{compat.PARTITION_ID:05}*.snappy.parquet")
    )
    if not glob_result:
        raise RuntimeError(
            f"Could not find partition {compat.PARTITION_ID} in folder {rows_uri!r}"
        )
    rows_uri = rows_uri.file(os.path.basename(glob_result[0]))

    sampled_path = uri.root("sampled", compat.WORKSPACE_NAME).run(
        config["dataset"]["sampled"]["run"]
    )

    module_path = (
        uri.root("prediction", compat.WORKSPACE_NAME)
        .executor(config["model"]["executorrun"])
        .model(config["model"]["modulerun"])
    )
    train_model_spec = json.loads(os.environ["train_model"])
    model_uri = (
        uri.root("prediction", compat.WORKSPACE_NAME)
        .executor(train_model_spec["executorrun"])
        .model(train_model_spec["modulerun"])
        .folder("model")
    )

    describe(
        config,
        run_path,
        attempt_number=compat.ATTEMPT_NUMBER,
        partition_id=compat.PARTITION_ID,
        rows_uri=rows_uri,
        data_path=sampled_path,
        module_path=module_path,
        model_uri=model_uri,
    )


if __name__ == "__main__":
    main()
