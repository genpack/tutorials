"""The ``Distributor`` is able to manage for all techstacks functionality to :meth:`~AbstractDistributor.distribute`
(starting subsequent train jobs) and :meth:`~AbstractDistributor.collect_modules` (await and retrieve all results).
:meth:`~AbstractDistributor.distribute` enables the user to have multiple train jobs (as specified per config) in parallel.
This call is of short duration and returns a UUID as reference. :meth:`~AbstractDistributor.collect_modules` provides a simple
call to await all specified training jobs to finish and returns a dict of all scores.
"""
import abc
import logging
from typing import Callable, Dict, List, Optional, TYPE_CHECKING, Any

from ell.env import configtools
from ell.env.env_abc import AbstractEnv
from ell.env.uri import URI

from ell.predictions import compat, utils
from ell.predictions.errors import DistributorException

if TYPE_CHECKING:
    from ell.predictions import Model

LOGGER = logging.getLogger(__name__)


class AbstractDistributor(abc.ABC):
    """Abstract base class for distributors."""

    def __init__(
        self,
        executor_path: str,
        config_filler: Optional[Callable[[dict], dict]] = None,
        env: AbstractEnv = compat.env,
        model_timeout: Optional[int] = None,
    ) -> None:
        self._agentrun_path = utils.ensure_uri(executor_path, is_folder=True)
        self._config_filler = config_filler
        self._env = env
        self._model_timeout = model_timeout

    @classmethod
    def create(
        cls,
        executor_path: URI,
        data_path: Optional[URI] = None,
        config_filler: Optional[Callable[[dict], dict]] = None,
        env: AbstractEnv = compat.env,
        model_timeout: Optional[str] = None,
        compute_budget: Optional[str] = None,
    ) -> "AbstractDistributor":
        if model_timeout:
            model_timeout = configtools.parse_timedelta(model_timeout)
            model_timeout = int(model_timeout.total_seconds())
        if compute_budget:
            compute_budget = configtools.parse_timedelta(compute_budget)
            compute_budget = int(compute_budget.total_seconds())

        # Imports down here to avoid circular imports
        if compat.ON_ECS:
            from ell.predictions.distributing import AWSDistributor

            if not model_timeout and compute_budget:
                raise ValueError(
                    "A model timeout and compute budget are required for the AWS distributor"
                )

            return AWSDistributor(
                executor_path=executor_path,
                config_filler=config_filler,
                env=env,
                model_timeout=model_timeout,
                compute_budget=compute_budget,
            )
        else:
            from ell.predictions.distributing import LocalDistributor

            if not data_path:
                raise TypeError(
                    "data_path must be provided to AbstractDistributor.create() in local "
                    "environment"
                )
            return LocalDistributor(
                executor_path=executor_path,
                data_path=data_path,
                config_filler=config_filler,
                env=env,
                model_timeout=model_timeout,
            )

    def distribute(self, config: dict) -> str:
        """Farms a new model to be trained.

        Args:
            config: Config for the model.

        Returns:
            The Run ID for the job.

        """
        if self._config_filler is not None:
            config = self._config_filler(config)

        return self._distribute(config)

    def collect_scores(self, runids: List[str]) -> Dict[str, Dict[str, Any]]:
        """Collects scores for the provided Run IDs.

        This internally waits for all runs to be finished.

        Args:
            runids: List of Run IDs to collect.

        Returns:
            Dictionary of runid -> scores.

        """
        try:
            self._wait_for_moduleruns(runids)
        except DistributorException as exc:
            # Collect results for runids which succeeded, then re-raise
            # the exception with the results attached
            incomplete_set = frozenset(exc.incomplete_runids)
            succeeded_runids = [r for r in runids if r not in incomplete_set]

            exc.results = self._load_scores(succeeded_runids)
            raise exc
        else:
            return self._load_scores(runids)

    def collect_modules(self, runids: List[str]) -> Dict[str, "Model"]:
        """Collects the model objects for the provided Run IDs.

        This internally waits for all runs to be finished.

        Args:
            runids: List of Run IDs to collect.

        Returns:
            Dictionary of runid -> model.

        """
        try:
            self._wait_for_moduleruns(runids)
        except DistributorException as exc:
            # Collect results for runids which succeeded, then re-raise
            # the exception with the results attached
            incomplete_set = frozenset(exc.incomplete_runids)
            succeeded_runids = [r for r in runids if r not in incomplete_set]

            exc.results = self._load_models(succeeded_runids)
            raise exc
        else:
            return self._load_models(runids)

    def _load_scores(self, runids: List[str]) -> Dict[str, dict]:
        all_scores = {}
        for modulerun in runids:
            scores_uri = self._agentrun_path.model(modulerun).file("scores.json")
            scores = self._env.read_jsonish(scores_uri)
            all_scores[modulerun] = scores

        LOGGER.info("Collected scores of %s models", len(all_scores))
        return all_scores

    def _load_models(self, runids: List[str]) -> Dict[str, "Model"]:
        models = {}
        for modulerun in runids:
            model_uri = self._agentrun_path.model(modulerun).folder("model")
            model = utils.load_model(model_uri, env=self._env)
            models[modulerun] = model

        LOGGER.info("Collected %s models", len(models), extra={"data": models})
        return models

    @abc.abstractmethod
    def _wait_for_moduleruns(self, runids: List[str]) -> None:
        raise NotImplementedError

    @abc.abstractmethod
    def _distribute(self, config: dict) -> str:
        raise NotImplementedError
