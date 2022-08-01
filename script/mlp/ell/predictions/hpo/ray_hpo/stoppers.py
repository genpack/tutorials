import abc
import logging
import time
from datetime import timedelta
from operator import itemgetter
from typing import Dict

from ell.predictions.distributing import AWSDistributor
from ell.predictions.hpo.utils import Trial

LOGGER = logging.getLogger(__name__)


class Stopper(abc.ABC):
    """Base class for HPO experiment stoppers"""

    @abc.abstractmethod
    def should_stop_experiment(self, trial: Trial) -> bool:
        """Returns True if the experiment should be stopped after this trial

        Args:
            trial: The latest Trial to be completed by the HPO

        Returns:
            True if experiment should be stopped
        """
        raise NotImplementedError


class BudgetStopper(Stopper):
    """Early stop a Ray experiment if the global distributor has run out of compute budget"""

    def __init__(self, distributor: AWSDistributor):
        self._distributor = distributor

    def __repr__(self):
        return f"{self.__class__.__name__}()"

    def should_stop_experiment(self, trial: Trial) -> bool:
        """Returns true if the distributor is out of budget"""
        if self._distributor.out_of_budget:
            LOGGER.info("Distributor is out of budget, early stopping")
            return True

        return False


class DurationStopper(Stopper):
    """Early stop an experiment if the experiment timeout has passed the duration"""

    def __init__(self, timeout: timedelta):
        self._timeout_seconds = timeout.total_seconds()
        self._start = None

    def __repr__(self):
        return f"{self.__class__.__name__}(timeout_seconds={self._timeout_seconds})"

    def should_stop_experiment(self, trial: Trial) -> bool:
        """Returns True if the experiment has been going for longer than the timeout"""
        if not self._start:
            self._start = time.monotonic()
            return False

        now = time.monotonic()
        if now - self._start >= self._timeout_seconds:
            LOGGER.info("Duration has been reached, early stopping")
            return True

        return False


class PlateauStopper(Stopper):
    """Early stop if the top models have not changed recently"""

    def __init__(
        self,
        metric: str,
        maximise: bool,
        patience: int,
        num_top_models: int = 1,
        delay: int = 0,
    ):
        if not isinstance(num_top_models, int) or num_top_models <= 0:
            raise ValueError("Number of top models must be a positive integer.")
        if not isinstance(patience, int) or patience <= 0:
            raise ValueError("Patience must be a positive integer.")
        if not isinstance(delay, int) or delay < 0:
            raise ValueError("The delay must be a non negative integer.")

        self._maximise = maximise
        self._metric = metric
        self._patience = patience
        self._stagnation = 0
        self._trial_ids = set()
        self._delay = delay
        self._num_top_models = num_top_models
        self._top_values: Dict[int, float] = {}

    def __repr__(self):
        return (
            f"{self.__class__.__name__}("
            f"metric={self._metric}, "
            f"maximise={self._maximise}, "
            f"patience={self._patience}, "
            f"num_top_models={self._num_top_models}, "
            f"delay={self._delay})"
        )

    def _register_trial(self, trial: Trial) -> bool:
        """Return a boolean representing if a given trial has to stop."""
        if trial.trial_id in self._trial_ids:
            return False

        self._trial_ids.add(trial.trial_id)

        new_potential_top = self._top_values.copy()
        new_potential_top[trial.trial_id] = trial.results[self._metric]
        # Sort dictionary by value, and take the top results
        new_potential_top = {
            k: v
            for k, v in sorted(
                new_potential_top.items(), key=itemgetter(1), reverse=True
            )[: self._num_top_models]
        }

        if new_potential_top == self._top_values and self._is_eligible_stopping_round():
            self._stagnation += 1
        else:
            self._stagnation = 0
            self._top_values = new_potential_top

        return False

    def _is_eligible_stopping_round(self) -> bool:
        """Determine whether the current round is eligible for stopping"""
        return (
            len(self._trial_ids) > self._delay
            and len(self._top_values) == self._num_top_models
        )

    def should_stop_experiment(self, trial: Trial) -> bool:
        """Returns True if we are past the delay and have reached max stagnation"""
        self._register_trial(trial)
        if self._is_eligible_stopping_round() and self._stagnation >= self._patience:
            LOGGER.info(
                "Early stopping after %s trials.",
                len(self._trial_ids),
            )
            return True

        return False


class OrStopper(Stopper):
    """Stopper that combines multiple stoppers via the OR operator"""

    def __init__(self, *stoppers: Stopper):
        self._stoppers = list(stoppers)

    def __repr__(self):
        return f"{self.__class__.__name__}(stoppers={self._stoppers})"

    def add_stopper(self, stopper: Stopper):
        """Adds an additional Stopper to the list of Stoppers"""
        self._stoppers.append(stopper)

    def should_stop_experiment(self, trial: Trial) -> bool:
        """Returns True if any stoppers ``stop_experiment()`` method return True"""
        return any(s.should_stop_experiment(trial) for s in self._stoppers)
