import datetime
import logging
import threading
import time
from typing import List

from ell.env.env_abc import AbstractEnv
from epp_api_workspace import EppAPI
from epp_api_workspace.jobs import PredictionModel

from ell.predictions import compat
from ell.predictions.errors import (
    FarmedModelsFailed,
    DistributorTimeoutError,
    DistributorComputeBudgetExhausted,
)
from ell.predictions.distributing.distributor_abc import AbstractDistributor

LOGGER = logging.getLogger(__name__)

FAILED_STATES = frozenset({"FAILED", "KILLED", "DIED", "TIMED_OUT"})
FINAL_STATES = frozenset({"SUCCEEDED"}).union(FAILED_STATES)
HOUR = 3600


class AWSDistributor(AbstractDistributor):
    """A Distributor to submit models to run on AWS.

    This distributor has the concept of a ``compute_budget``, the total cumulative time
    all distributed jobs can use. Access to this budget is controlled by thread lock, to
    ensure even in a multi-threaded context the budget is respected.
    """

    def __init__(
        self,
        executor_path,
        config_filler,
        env: AbstractEnv,
        model_timeout: int,
        compute_budget: int,
    ) -> None:
        super().__init__(executor_path, config_filler, env, model_timeout)
        workspace = EppAPI()
        self._agent = workspace.prediction.get_job(compat.EXECUTORRUN)
        self._compute_budget = compute_budget
        self._model_timeout = model_timeout
        self._remaining_compute_budget = self._compute_budget
        self._submitted_moduleruns = set()
        self._reclaimed_moduleruns = set()
        self._out_of_budget = False

        # Create a thread lock to protect the budget
        self._lock = threading.RLock()
        self._submit_condition = threading.Condition()

    def __getstate__(self):
        state = self.__dict__.copy()
        del state["_agent"]
        del state["_env"]
        return state

    def __setstate__(self, state):
        self.__dict__.update(state)
        workspace = EppAPI()
        self._agent = workspace.prediction.get_job(compat.EXECUTORRUN)
        self._env = compat.env

    @property
    def out_of_budget(self) -> bool:
        """Returns ``True`` if the distributor can't submit anymore due to lack of budget"""
        return self._out_of_budget

    def _distribute(self, config: dict) -> str:
        """Tries to distribute a model, waiting if needed for additional compute budget.

        This method is blocking if the distributor is waiting for compute budget to become
        available. It also requires the thread lock, to prevent multiple access to the
        budget.

        Args:
            config: The config to submit

        Returns:
            The modulerun of the submitted job

        Raises:
            DistributorComputeBudgetExhausted: If it is impossible for the job to ever be
                distributed due to compute budget limitations
        """
        with self._lock:
            LOGGER.info(
                "Attempting to distribute a new model: %.2f compute hours remaining",
                self._remaining_compute_budget / HOUR,
            )

            while True:
                try:
                    return self._try_submit_model(config)
                except DistributorComputeBudgetExhausted as exc:
                    max_compute_refund = self._calculate_max_compute_refund()
                    max_budget = max_compute_refund + self._remaining_compute_budget
                    if max_budget > self._model_timeout:
                        LOGGER.info(
                            "There may be enough budget once some running models finish. "
                            "Potential budget is %.2f hours (%.2f required).",
                            max_budget / HOUR,
                            self._model_timeout / HOUR,
                        )
                        time.sleep(30)
                    else:
                        LOGGER.info(
                            "There is definitely not enough budget to submit more models."
                        )
                        self._out_of_budget = True
                        raise exc

    def _try_submit_model(self, config: dict) -> str:
        """Tries to submit a model if sufficient compute budget remains.

        Will set the timeout of the submitted model to ``self._model_timeout``.

        Args:
            config: The config to submit

        Returns:
            The runid of the submitted job

        Raises:
            DistributorComputeBudgetExhausted: If the remaining compute budget is less than
                the model timeout
        """
        if self._remaining_compute_budget < self._model_timeout:
            raise DistributorComputeBudgetExhausted(
                f"Insufficient compute hours to distribute a model, at least "
                f"{self._model_timeout / HOUR:.2f} hours are required but only "
                f"{self._remaining_compute_budget / HOUR:.2f} remain.",
            )

        # Set timeouts and enforce no babushka in distributor section
        config = config.copy()
        timeout_spec = f"{self._model_timeout}s"
        config["timeout"] = timeout_spec
        config["distributor"] = {
            "model_timeout": timeout_spec,
            "total_compute_budget": timeout_spec,
        }

        model = self._agent.submit_model(config)
        self._submitted_moduleruns.add(model.runid)
        self._remaining_compute_budget -= self._model_timeout
        LOGGER.info(
            "Farmed new model %r. %.2f compute hours remaining",
            model,
            self._remaining_compute_budget / HOUR,
        )

        return model.runid

    def _wait_for_moduleruns(self, runids: List[str]) -> None:
        incomplete = runids.copy()

        failed_runs = []
        timed_out_runs = []
        while incomplete:
            to_remove = []
            cur_states = {}
            for modulerun in incomplete:
                model = self._agent.get_model(modulerun)
                model.refresh()

                if model.state in FINAL_STATES:
                    self._try_reclaim_model(model)
                    to_remove.append(modulerun)

                    if model.state == "SUCCEEDED":
                        LOGGER.info("Modelrun %s SUCCEEDED", modulerun)
                    elif model.state in FAILED_STATES:
                        LOGGER.info("Modelrun %s %s", modulerun, model.state)
                        failed_runs.append(modulerun)
                        if model.state == "TIMED_OUT":
                            timed_out_runs.append(modulerun)
                else:
                    cur_states[modulerun] = model.state

                time.sleep(30)

            LOGGER.debug("Current modulerun states", extra={"data": cur_states})

            for modulerun in to_remove:
                incomplete.remove(modulerun)

        if timed_out_runs:
            LOGGER.error(
                "%s moduleruns timed out",
                len(timed_out_runs),
                extra={"data": timed_out_runs},
            )
            raise DistributorTimeoutError(
                f"{len(timed_out_runs)} moduleruns timed out after "
                f"{self._model_timeout / 60:.2f} minutes",
                incomplete_runids=failed_runs,
            )

        if failed_runs:
            LOGGER.error(
                "%s moduleruns ended in one of these states: %s",
                len(failed_runs),
                FAILED_STATES,
                extra={"data": failed_runs},
            )
            raise FarmedModelsFailed(
                f"{len(failed_runs)} moduleruns failed",
                incomplete_runids=failed_runs,
            )

    def _calculate_max_compute_refund(self) -> int:
        """Calculate maximum compute time that could be reimbursed from submitted runs.

        Checks each submitted model and reimburses the compute time if finished.
        If a job is unfinished, we take the best case where the job ends immediately.

        Returns:
            The maximum number of seconds that could be reimbursed if all currently
            running jobs submitted by the distributor ended immediately.
        """
        max_compute_refund = 0
        for modulerun in self._submitted_moduleruns - self._reclaimed_moduleruns:
            model = self._agent.get_model(modulerun)
            model.refresh()

            if model.state in FINAL_STATES:
                self._try_reclaim_model(model)
            else:
                start_time = model.submitted_on
                now = datetime.datetime.now(tz=start_time.tzinfo)
                runtime = int((now - start_time).total_seconds())
                max_compute_refund += self._model_timeout - runtime

        return max_compute_refund

    def _try_reclaim_model(self, model: PredictionModel):
        """Reimburses unused compute hours for a model.

        If the model is not finished, nothing is reimbursed. This method makes use of
        a thread lock to ensure each model is only reclaimed once.

        Args:
            model: The job to reimburse
        """
        with self._lock:
            if (
                model.state in FINAL_STATES
                and model.runid not in self._reclaimed_moduleruns
            ):
                # Reimburse unused compute hours
                self._reclaimed_moduleruns.add(model.runid)
                duration = int((model.ended_on - model.submitted_on).total_seconds())
                self._remaining_compute_budget += self._model_timeout - duration
