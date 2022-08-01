"""
Abstract base class for hyperparameter optimisation algorithms.
"""
import functools
import inspect
from abc import ABC, abstractmethod
from copy import deepcopy
from typing import Dict, Type, Any, Tuple, Union, List, ClassVar, Optional

import pandas as pd
from ell.env import uri
from ell.env.configtools import parse_timedelta
from ell.env.uri import URI

from ell.predictions.distributing import AbstractDistributor
from .utils import (
    TRIAL_AGGREGATOR_MAP,
    LOGGER,
    aggregate_trial_scores,
    set_random_seed,
    Trial,
    configure_model_config,
)
from .. import compat
from ..errors import DistributorComputeBudgetExhausted, DistributorException

_HPO_REGISTRY: Dict[str, Type["AbstractTuner"]] = {}


class AbstractTuner(ABC):
    """Abstract base class for HPO Algorithms

    Args:
        config: The full predictions config
    """

    #: Number of HPO trials to run by default. Each trial corresponds to a modulerun. By
    #: default, effectively infinite trials will be run and we rely on a duration,
    #: timeout, or compute budget to end the experiment.
    DEFAULT_NUM_TRIALS: ClassVar[int] = float("inf")
    #: Number of models to run in parallel, either eagerly or in batches
    DEFAULT_NUM_PARALLEL: ClassVar[int] = 8
    #: The supported search space distributions by HPO algorithms.
    SUPPORTED_DISTRIBUTIONS = frozenset(
        {
            "uniform",
            "loguniform",
            "randint",
            "lograndint",
            "normal",
            "choice",
        }
    )

    def __init__(self, config: Dict[str, Any]):
        config = deepcopy(config)

        hpo_config = config.pop("hpo")
        self._model_config = config
        self._metric = hpo_config.get("metric", "gini_coefficient")
        self._maximise = hpo_config.get("maximise", True)
        self._best_trial: Optional[Trial] = None

        # Allow for running each trial over multiple months
        self._sample_sets = hpo_config.get("sample_sets", [])
        self._trial_aggregator = hpo_config.get("trial_aggregator", "mean")
        if self._trial_aggregator not in TRIAL_AGGREGATOR_MAP:
            raise ValueError(
                f"{self._trial_aggregator} is not a supported trial aggregator. "
                f"Expected one of {TRIAL_AGGREGATOR_MAP.keys()}"
            )

        # Set up run duration, either in time or in number of trials
        time_spec = hpo_config.get("duration")
        self._duration = parse_timedelta(time_spec) if time_spec else None
        self._num_trials = hpo_config.get("num_trials", self.DEFAULT_NUM_TRIALS)
        if self._duration is None and self._num_trials == self.DEFAULT_NUM_TRIALS:
            raise ValueError("At least one of duration or num_trials must be specified")

        # Number of concurrent runs to run at once. This may be in batches, or simply
        # the maximum number of concurrent executions, depending on the algorithm
        self._num_parallel = hpo_config.get("num_parallel", self.DEFAULT_NUM_PARALLEL)

        # Set up search space
        space_spec = hpo_config["space"]
        if not space_spec:
            raise ValueError("The space specification cannot be empty!")
        # Configure feature selection if provided
        features = self._model_config["model"]["features"]
        if hpo_config.get("feature_select") and "num_features" not in space_spec:
            num_features_spec = self._configure_num_features_spec(
                features, hpo_config["feature_select"]
            )
            space_spec["num_features"] = num_features_spec

        self._space, self._interpretation_args = self._configure_search_space(
            space_spec
        )

        # Get parameters and set seed
        parameters = hpo_config.get("parameters", {})
        self._random_seed = parameters.pop("random_state", parameters.pop("seed", 0))
        set_random_seed(self._random_seed)
        self._parameters = parameters

        # Set up search algorithm
        self._searcher = self._configure_searcher()
        warm_start_runid = hpo_config.get("warm_start")
        if warm_start_runid:
            executor_path = uri.root("prediction", compat.WORKSPACE_NAME).executor(
                warm_start_runid
            )
            self.warm_start(executor_path)

        # Create a function to compare two trials
        self._trial_comparitor = functools.partial(
            max if self._maximise else min,
            key=lambda t: t.results[self._metric],
        )

    @staticmethod
    def _configure_num_features_spec(
        features: List[str], feature_select_spec: Union[bool, Dict[str, int]]
    ) -> Dict[str, Any]:
        """Configures the space specification for ``num_features``.

        Args:
            features: The list of features used by the model
            feature_select_spec: The value of config["hpo"]["feature_select"]. If a bool
                features are selected from the interval [1, len(features)]. If a dict
                the minimum and maximum features specified determine the interval

        Returns:
            A dictionary containing the config specification for the distribution of
            the number of features to select.
        """
        if not isinstance(feature_select_spec, dict):
            feature_select_spec = {}

        min_feats = feature_select_spec.get("min_features", 1)
        max_feats = feature_select_spec.get("max_features", len(features))
        if min_feats >= max_feats:
            raise ValueError("min_features must be less than max_features")

        num_features_spec = dict(
            distribution="randint",
            range=[max(min_feats, 1), min(max_feats, len(features))],
        )

        return num_features_spec

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        if not inspect.isabstract(cls):
            _HPO_REGISTRY[cls.__name__] = cls

    @classmethod
    def from_config(cls, config: dict) -> "AbstractTuner":
        """Create a model instance from a config."""
        hpo_name = config["hpo"]["algorithm"]
        if hpo_name not in _HPO_REGISTRY:
            raise ValueError(f"Unknown HPO algorithm {hpo_name!r}")
        hpo_cls = _HPO_REGISTRY[hpo_name]

        return hpo_cls(config)

    @classmethod
    @abstractmethod
    def _configure_search_space(
        cls, space_spec: Dict[str, Dict[str, Any]]
    ) -> Tuple[Any, Dict[str, Any]]:
        """Converts a config space spec into a format supported by the HPO algorithm

        Args:
            space_spec: The space specification located at config["hpo"]["space"]

        Returns:
            A 2-tuple containing the search space as the first element, and a dictionary
            of interpretation arguments as the second element. The configured search
            space will be in the format expected by the internal HPO algorithm.
            The items in the interpretation arguments dict are passed as kwargs to
            :meth:`~_interpret_parameters`.
        """
        raise NotImplementedError

    @abstractmethod
    def _configure_searcher(self) -> Any:
        """Initialises the HPO search algorithm."""
        raise NotImplementedError

    @abstractmethod
    def warm_start(self, executor_path: URI):
        """If possible, load the searcher state from a previous HPO run

        Args:
            executor_path: The executorrun directory of the HPO to warm start from
        """
        raise NotImplementedError

    @staticmethod
    def _interpret_parameters(
        parameters: Dict[str, Any],
        *,
        normal_limits: Dict[str, Tuple[float, float]] = None,
        **kwargs,
    ) -> Dict[str, Any]:
        """Converts parameters passed in by HPO into parameters accepted by the model

        By default, 2 interpretations are performed. ``eta_k`` is transformed into
        ``eta``, and any limits on normal distributions are enforced.

        Args:
            parameters: A dictionary of parameters to interpret
            normal_limits: A mapping from parameter name to a 2-tuple. The 2-tuple
                defines the minimum and maximum value the parameter can take.
                This is only used for normal distributions.
            **kwargs: Any additional arguments that are required to interpret the
                provided parameters. These vary per HPO algorithm.

        Returns:
            A dictionary mapping parameter names to interpreted values.
        """
        parameters = deepcopy(parameters)
        if "eta_k" in parameters:
            eta_k = parameters.pop("eta_k")
            n_estimators = parameters["n_estimators"]
            parameters["eta"] = min(eta_k, n_estimators) / n_estimators

        # If any normal distributions are present, make sure they are between the
        # specified floor and ceiling
        normal_limits = normal_limits or {}
        for parameter, (floor, ceiling) in normal_limits.items():
            if floor is not None:
                parameters[parameter] = max(floor, parameters[parameter])
            if ceiling is not None:
                parameters[parameter] = min(ceiling, parameters[parameter])

        return parameters

    @staticmethod
    def _compute_multi_sample_trial(
        trial: Trial,
        base_config: Dict[str, Any],
        distributor: "AbstractDistributor",
        sample_sets: List[str],
        trial_aggregator: str,
    ) -> Trial:
        """Submits and collects models for a multi sample trial.

        A model is submitted for each sample set, and the results are aggregated into a
        single results dictionary. If only some of the models can be submitted, the
        trial will continue with those that were. If not all of the models succeed,
        the results will be calculated from those that did.

        Args:
            trial: The HPO trial to compute
            base_config: The full config to distribute. The ``train`` and ``test`` keys will be
                modified to reflect each sample set
            distributor: The distributor used to submit and collect models
            sample_sets: The name of the sampler datasets to run on. Each element is
                interpreted as a suffix, and is appended to ``train_`` and ``test_``
            trial_aggregator: The function to use to aggregate the results. Must be one
                of mean, median, min, max

        Returns:
           The completed trial, with moduleruns and results filled in. Results are
           aggregated across all models ran.
        """
        try:
            LOGGER.info("Submitting trial: %s", trial)
            config = configure_model_config(base_config, trial.parameters)
            config = deepcopy(config)

            for sample_set in sample_sets:
                config["train"] = "train_" + sample_set
                config["test"] = "test_" + sample_set
                try:
                    trial.moduleruns.append(distributor.distribute(config))
                except DistributorComputeBudgetExhausted as exc:
                    if trial.moduleruns:
                        LOGGER.warning(
                            "Distributor ran out of budget after %s models. "
                            "Trial will continue with successfully submitted models",
                            len(trial.moduleruns),
                        )
                    else:
                        raise exc
            scores = distributor.collect_scores(trial.moduleruns)
            trial.results = aggregate_trial_scores(scores, trial_aggregator)
        except DistributorException as exc:
            if exc.results:
                LOGGER.warning(
                    "%s models in this trial did not succeed. "
                    "Scores will be computed from successful models",
                    len(exc.incomplete_runids),
                )
                trial.exception = exc
                trial.results = aggregate_trial_scores(exc.results, trial_aggregator)
            else:
                trial.exception = exc
                trial.failed = True
        except Exception as exc:
            trial.exception = exc
            trial.failed = True
        finally:
            return trial

    @staticmethod
    def _compute_single_trial(
        trial: Trial, base_config: Dict[str, Any], distributor: "AbstractDistributor"
    ) -> Trial:
        """Farms and collects a single model for an HPO trial.

        Args:
            trial: The HPO trial to compute
            base_config: The full config to distribute
            distributor: The distributor used to submit and collect models

        Returns:
            The completed trial, with moduleruns and results filled in.
        """
        try:
            LOGGER.info("Submitting trial: %s", trial)
            config = configure_model_config(base_config, trial.parameters)
            runid = distributor.distribute(config)
            trial.moduleruns.append(runid)
            scores = distributor.collect_scores([runid])
            trial.results = scores[runid]
        except Exception as exc:
            trial.exception = exc
            trial.failed = True
        finally:
            return trial

    def optimise(self, distributor: AbstractDistributor) -> Dict[str, Any]:
        """The optimisation code called by :func:`~ell.predictions.api.optimise_hyper_parameters`

        In addition, a pandas dataframe containing all the trial results is written
        out to ``executor_path/trials.parquet``, and a JSON representation of all the
        trials is written to ``executor_path/trials.json``.

        Args:
            distributor: The distributor to use to submit models

        Returns:
            A dictionary containing the results of the HPO. The dictionary will have the
            following items:

            - ``best_moduleruns``: A list of the runids of the best trial
            - ``best_parameters``: The parameters of the best trial
            - ``best_score``: The value of the target metric achieved by the best trial
            - ``best_metrics``: The full scores dictionary of the best trial

        .. tip::
                The parameters under ``best_parameters`` are the parameters before
                JSONPaths have been resolved. It is best practice to get the parameter
                values directly from the config of the best model.
        """
        trials = self._optimise(distributor)

        # Write out information for all the completed trials
        # noinspection PyProtectedMember
        executor_path = distributor._agentrun_path
        compat.env.write_jsonish(
            executor_path.file("trials.json"),
            [trial.to_json() for trial in trials],
        )
        trials_df = pd.DataFrame.from_records(
            [trial.to_record() for trial in trials],
            index="trial_id",
            exclude=["exception"],
        )
        trials_df.to_parquet(executor_path.file("trials.parquet"))

        if not self._best_trial:
            raise ValueError("HPO did not find a best trial. Failing")

        results = {
            "best_moduleruns": self._best_trial.moduleruns,
            "best_parameters": self._best_trial.parameters,
            "best_trial": self._best_trial.to_json(),
            "best_score": self._best_trial.results[self._metric],
            "best_metrics": self._best_trial.results,
        }
        LOGGER.info("HPO results: ", extra={"data": results})

        return results

    def _optimise(self, distributor: AbstractDistributor) -> List[Trial]:
        """The subclass specific method to perform the optimisation

        This method must set ``self._best_trial`` with the value of the best trial
        found by the HPO

        Args:
            distributor: The distributor to use to submit models

        Returns:
            The full list of trials performed by the HPO
        """
        raise NotImplementedError
