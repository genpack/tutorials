import concurrent.futures
import inspect
import logging
import tempfile
from abc import ABC
from concurrent.futures import wait, ThreadPoolExecutor
from copy import deepcopy
from functools import partial
from typing import Dict, Any, Type, Tuple, List, ClassVar

from ell.env.uri import URI

from ell.predictions import compat
from ell.predictions.distributing import AbstractDistributor, AWSDistributor
from .stoppers import BudgetStopper, DurationStopper, PlateauStopper, OrStopper
from ..hpo_abc import AbstractTuner
from ..utils import Trial
from ...utils import utils

try:
    from ray import tune
    from ray.tune.suggest import Searcher
except ModuleNotFoundError:
    tune = None
    Searcher = None

LOGGER = logging.getLogger(__name__)

_SUBMISSION_STRATEGIES = {
    "eager": concurrent.futures.FIRST_COMPLETED,
    "batch": concurrent.futures.ALL_COMPLETED,
}


class RayAbstractTuner(AbstractTuner, ABC):
    """Abstract class for all Ray Tune HPO algorithms

    All subclasses of this class must implement the following class variables:

    - ``DEFAULT_SUBMISSION_STRATEGY``: One of ``eager`` and ``batch`` determining how
      the HPO should submit jobs.
    - ``_INITIAL_POINTS_PARAMETER``: The name of the parameter accepted by the
      searcher that determines the number of random trials to start with.
    - ``_RANDOM_STATE_PARAMETER``: The name of the parameter accepted by the
      searcher that determines the random state.
    - ``_SEARCHER_CLS``: The subclass of :class:`ray.tune.suggest.Searcher` to use.

    Args:
        config: The full predictions config
    """

    #: Each HPO algorithm supports a different default behaviour for batching
    DEFAULT_SUBMISSION_STRATEGY: ClassVar[str]

    _INITIAL_POINTS_PARAMETER: ClassVar[str]
    _RANDOM_STATE_PARAMETER: ClassVar[str]
    _SEARCHER_CLS: ClassVar[Type[Searcher]]

    def __init__(self, config: Dict[str, Any]) -> None:
        super().__init__(config)
        if tune is None:
            raise RuntimeError("Ray tune is not installed!")

        config = deepcopy(config)
        hpo_config = config.pop("hpo")

        # Set up all forms of Early Stopping
        self._stopper = OrStopper()
        plateau_stopping_spec = hpo_config.get("early_stopping", {})
        if plateau_stopping_spec:
            num_top_models = plateau_stopping_spec.get("num_top_models", 1)
            patience = plateau_stopping_spec["patience"]
            plateau_stopper = PlateauStopper(
                metric=self._metric,
                maximise=self._maximise,
                patience=patience,
                num_top_models=num_top_models,
                delay=self._parameters.get("num_initial_points", self._num_parallel),
            )
            self._stopper.add_stopper(plateau_stopper)
        if self._duration:
            self._stopper.add_stopper(DurationStopper(self._duration))

        # Set the submission strategy for the HPO (batching or eager)
        submission_strategy = hpo_config.pop(
            "submission_strategy", self.DEFAULT_SUBMISSION_STRATEGY
        )
        if submission_strategy not in _SUBMISSION_STRATEGIES:
            raise ValueError(
                f"{submission_strategy} is not a supported submission strategy."
                f" Expected one of {list(_SUBMISSION_STRATEGIES.keys())}"
            )
        self._submission_strategy = _SUBMISSION_STRATEGIES[submission_strategy]

    def __init_subclass__(cls, **kwargs):
        """Ensure that all subclasses implement the required class attributes"""
        required = (
            "DEFAULT_SUBMISSION_STRATEGY",
            "_INITIAL_POINTS_PARAMETER",
            "_RANDOM_STATE_PARAMETER",
            "_SEARCHER_CLS",
        )
        if not (inspect.isabstract(cls) or issubclass(cls, ABC)):
            if not all(getattr(cls, attr) for attr in required):
                raise TypeError(f"Subclasses of {cls.__name__} must define {required}")
        return super().__init_subclass__(**kwargs)

    def _configure_searcher(self) -> Searcher:
        """Initialises the HPO search algorithm.

        As all search algorithms have a different name for the initial points
        parameter we replace it in the parameter dict with the expected name
        """
        mode = "max" if self._maximise else "min"
        parameters = self._parameters.copy()
        parameters[self._INITIAL_POINTS_PARAMETER] = parameters.pop(
            "num_initial_points", self._num_parallel
        )
        parameters[self._RANDOM_STATE_PARAMETER] = self._random_seed

        searcher = self._SEARCHER_CLS(**parameters)
        res = searcher.set_search_properties(
            metric=self._metric, mode=mode, config=self._space
        )
        if not res:
            raise ValueError("Could not set up searcher")
        return searcher

    @classmethod
    def _configure_search_space(
        cls, space_spec: Dict[str, Dict[str, Any]]
    ) -> Tuple[Dict[str, "tune.sample.Domain"], Dict[str, Any]]:
        space = {}
        normal_limits = {}
        space_spec = deepcopy(space_spec)
        if "eta_k" in space_spec and "n_estimators" not in space_spec:
            raise ValueError("eta_k is only supported if n_estimators is also supplied")

        for parameter, spec in space_spec.items():
            distribution_name = spec.pop("distribution", None)
            if distribution_name not in cls.SUPPORTED_DISTRIBUTIONS:
                raise ValueError(
                    f"{cls.__name__} does not support {distribution_name} distributions"
                )

            if distribution_name == "choice":
                distribution_kwargs = dict(categories=spec["choices"])
            else:
                if distribution_name == "normal":
                    distribution_name = "randn"
                    distribution_kwargs = dict(mean=spec["mean"], sd=spec["std"])
                    normal_limits[parameter] = (
                        spec.get("floor"),
                        spec.get("ceiling"),
                    )
                else:
                    distribution_kwargs = dict(
                        lower=min(spec["range"]), upper=max(spec["range"])
                    )

                    # By default randint draws from the half open interval [low, high)
                    # so we add 1 to the upper bound to make it a closed interval.
                    # This is only an issue for randint without a step specified.
                    if distribution_name == "randint" and "step" not in spec:
                        distribution_kwargs["upper"] += 1

                    if "step" in spec:
                        distribution_kwargs.update(q=spec["step"])
                        distribution_name = f"q{distribution_name}"

                    if "base" in spec:
                        distribution_kwargs.update(base=spec["base"])

            distribution = getattr(tune, distribution_name)
            space[parameter] = distribution(**distribution_kwargs)

        interpretation_args = dict(normal_limits=normal_limits)

        return space, interpretation_args

    def warm_start(self, executor_path: str):
        """Warm starts a Ray HPO searcher

        Most Ray searchers support a :meth:`~ray.tune.suggest.Searcher.restore()`
        method, that loads the searcher state from a pickled file produced during
        a previous experiment. We look for this ``.pkl`` file, download it to a
        temporary directory, then restore the searcher from this state.

        Args:
            executor_path: The executorrun directory of the HPO to warm start from
        """
        executor_path = utils.ensure_uri(executor_path, is_folder=True)
        state_uri = executor_path.folder("etc").file("searcher_state.pkl")
        fs = compat.env.get_fs_for_uri(executor_path)
        if not fs.exists(executor_path):
            raise FileNotFoundError(
                f"A searcher state could not be found at {state_uri}"
            )

        LOGGER.info("Resuming searcher state: %s", state_uri)

        with tempfile.TemporaryDirectory() as tmpdir:
            fs.get(state_uri, f"{tmpdir}/searcher_state.pkl")
            self._searcher.restore(f"{tmpdir}/searcher_state.pkl")

    def _persist_searcher(self, executor_path: URI):
        """Save the searcher state to S3

        Args:
            executor_path: The root directory to save the state to.
        """
        fs = compat.env.get_fs_for_uri(executor_path)
        filename = f"searcher_state.pkl"

        with tempfile.TemporaryDirectory() as tmpdir:
            save_path = f"{tmpdir}/{filename}"
            self._searcher.save(save_path)
            fs.put(save_path, executor_path.folder("etc").file(filename))

        LOGGER.info("Persisting searcher state")

    def _suggest(self, trial_id: int) -> Trial:
        """Suggests a new trial to attempt.

        Parameters are retrieved from the suggester, and then interpreted

        Args:
            trial_id: The id of the trial

        Returns:
            The suggested trial
        """
        raw_params = self._searcher.suggest(str(trial_id))
        parameters = self._interpret_parameters(raw_params, **self._interpretation_args)
        return Trial(trial_id=trial_id, parameters=parameters)

    def _process_trial(self, trial: Trial) -> bool:
        """Process a completed HPO trial.

        First the searcher is updated with the results of the trial. We then check if
        we have a new best trial. Finally, we evaluate whether to early stop after this
        trial.

        Args:
            trial: The completed HPO trial

        Returns:
            True if we are to early stop after this trial
        """
        self._searcher.on_trial_complete(
            str(trial.trial_id), trial.results, trial.failed
        )

        if trial.failed:
            LOGGER.info("Trial failed: %s", trial, exc_info=trial.exception)
        else:
            LOGGER.info("Trial succeeded: %s", trial)
            if self._best_trial is None:
                self._best_trial = trial
            else:
                self._best_trial = self._trial_comparitor(self._best_trial, trial)
        if self._best_trial is trial:
            LOGGER.info("Best trial updated: %s", self._best_trial)

        # Check for early stopping
        early_stop = self._stopper.should_stop_experiment(trial)
        if early_stop:
            LOGGER.info("Early stopping. No more trials will be scheduled")

        return early_stop

    def _optimise(self, distributor: AbstractDistributor) -> List[Trial]:
        """Optimisation loop for Ray HPO algorithms

        We create a thread pool to submit and monitor each job in a seperate thread.

        Args:
            distributor: The distributor to use to submit models

        Returns:
            The full list of trials performed by the HPO
        """
        # Add a budget stopper if we are distributing to AWS
        if isinstance(distributor, AWSDistributor):
            self._stopper.add_stopper(BudgetStopper(distributor))

        # Reduce logging spam from distributors
        distributor_logger = logging.getLogger(distributor.__module__)
        distributor_logger.setLevel(logging.INFO)

        # Create the trial runner function that accepts a trial to run
        if self._sample_sets:
            trial_runner = partial(
                self._compute_multi_sample_trial,
                base_config=self._model_config,
                trial_aggregator=self._trial_aggregator,
                sample_sets=self._sample_sets,
                distributor=distributor,
            )
        else:
            trial_runner = partial(
                self._compute_single_trial,
                base_config=self._model_config,
                distributor=distributor,
            )

        early_stop = False
        trials = []
        with ThreadPoolExecutor(max_workers=self._num_parallel) as executor:
            # Set up and submit first batch
            first_trials = [self._suggest(i) for i in range(self._num_parallel)]
            futures = set(
                executor.submit(trial_runner, trial) for trial in first_trials
            )

            trial_number = len(futures)
            while futures:
                done, _ = wait(futures, return_when=self._submission_strategy)

                # Process the results of the completed trials
                for future in done:
                    trial = future.result()
                    trials.append(trial)
                    early_stop = self._process_trial(trial) or early_stop
                    futures.remove(future)

                # Refill the working pool if there are still jobs to schedule
                for i in range(len(done)):
                    if trial_number < self._num_trials and not early_stop:
                        new_trial = self._suggest(trial_number)
                        LOGGER.info("Scheduling trial: %s", new_trial)
                        futures.add(executor.submit(trial_runner, new_trial))
                        trial_number += 1

                # Save the latest iteration of the searcher
                # noinspection PyProtectedMember
                self._persist_searcher(distributor._agentrun_path)

        return trials
