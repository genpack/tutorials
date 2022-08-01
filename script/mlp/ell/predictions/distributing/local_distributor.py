import concurrent.futures
import logging
import os
import uuid
from typing import Callable, Dict, List, Optional

from ell.env.env_abc import AbstractEnv

import ell.predictions
from ell.predictions import compat, utils
from ell.predictions.errors import FarmedModelsFailed, DistributorTimeoutError
from ell.predictions.distributing.distributor_abc import AbstractDistributor

LOGGER = logging.getLogger(__name__)


class LocalDistributor(AbstractDistributor):
    """A Distributor to run models locally.

    This distributor makes use of a thread pool to run multiple models concurrently.
    """

    def __init__(
        self,
        executor_path: str,
        data_path: str,
        config_filler: Optional[Callable[[dict], dict]] = None,
        max_workers: Optional[int] = None,
        env: AbstractEnv = compat.env,
        model_timeout: Optional[int] = None,
    ):
        super().__init__(executor_path, config_filler, env, model_timeout)
        recommended_workers = min(32, os.cpu_count() + 4)
        if max_workers is not None and max_workers > recommended_workers:
            LOGGER.warning(
                f"Number of workers set to {max_workers} "
                f"which is above recommended value: {recommended_workers}"
            )
        self._data_path = utils.ensure_uri(data_path, is_folder=True)
        self._max_workers = max_workers
        self._executor = concurrent.futures.ThreadPoolExecutor(max_workers=max_workers)
        self._futures: Dict[concurrent.futures.Future, str] = {}

    def __reduce__(self):
        return LocalDistributor, (
            self._agentrun_path,
            self._data_path,
            self._config_filler,
            self._max_workers,
        )

    def _distribute(self, config: dict) -> str:
        # 0. create new unique uuid for the run
        runid = str(uuid.uuid4())
        LOGGER.info("Farming a new model with runid %r", runid)
        module_path = self._agentrun_path.model(runid)

        # 1. persist config file
        config_uri = module_path.file("config.json")
        self._env.write_jsonish(uri=config_uri, data=config)

        # 2. submit job to executor
        LOGGER.info("Submitting job to executor")
        future = self._executor.submit(
            ell.predictions.train, config, module_path, self._data_path
        )
        self._futures[future] = runid

        return runid

    def _wait_for_moduleruns(self, runids: List[str]) -> None:
        runid_set = frozenset(runids)
        missing_runids = frozenset(runids) - frozenset(self._futures.values())
        if missing_runids:
            LOGGER.error(
                "Trying to collect %s runs which were not submitted by this distributor",
                len(missing_runids),
                extra={"data": sorted(missing_runids)},
            )
            raise ValueError(
                "Cannot collect runs which were not submitted by this distributor"
            )

        futures = [fut for fut, runid in self._futures.items() if runid in runid_set]
        exceptions = {}

        try:
            for fut in concurrent.futures.as_completed(
                futures, timeout=self._model_timeout
            ):
                runid = self._futures[fut]
                LOGGER.debug("Run %r completed", runid)
                exc = fut.exception()
                if exc is not None:
                    exceptions[runid] = exc
        except concurrent.futures.TimeoutError as exc:
            incomplete_runids = [
                runid for fut, runid in self._futures.items() if not fut.done()
            ]
            incomplete_runids.extend(exceptions.keys())
            raise DistributorTimeoutError(
                f"Timeout whilst waiting for moduleruns to complete after "
                f"{self._model_timeout} seconds",
                incomplete_runids=incomplete_runids,
            ) from exc

        if exceptions:
            LOGGER.error(
                "%s child models raised unhandled exceptions",
                len(exceptions),
                extra=dict(data=exceptions, json_default=repr),
            )
            for runid, exc in exceptions.items():
                LOGGER.error("Exception from run %r", runid, exc_info=exc)
            raise FarmedModelsFailed(
                f"{len(exceptions)} moduleruns failed",
                incomplete_runids=list(exceptions.keys()),
            )
