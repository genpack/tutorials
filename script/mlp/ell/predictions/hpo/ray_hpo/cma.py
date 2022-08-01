import logging

from .ray_hpo_abc import RayAbstractTuner

try:
    from ray import tune
    from ray.tune.suggest.optuna import OptunaSearch
    import optuna
except ModuleNotFoundError:
    tune = None
    OptunaSearch = None
    optuna = None

LOGGER = logging.getLogger(__name__)


class CmaEs(RayAbstractTuner):
    """Class for CMA-ES optimisation

    This HPO algorithm makes use of :class:`ray.tune.suggest.optuna.OptunaSearch`
    """

    #: By default, CMA-ES eagerly collects and submits models.
    DEFAULT_SUBMISSION_STRATEGY = "eager"

    #: CMA-ES optimisation does not support normal distributions.
    SUPPORTED_DISTRIBUTIONS = frozenset(
        {
            "uniform",
            "loguniform",
            "randint",
            "lograndint",
            "choice",
        }
    )
    _SEARCHER_CLS = OptunaSearch
    _INITIAL_POINTS_PARAMETER = "n_startup_trials"
    _RANDOM_STATE_PARAMETER = "seed"

    def _configure_searcher(self) -> OptunaSearch:
        """Initialises the CMA search algorithm.

        Unlike other Ray searchers, we need to create an Optuna Sampler with the
        desired parameters, and then feed this sampler to the Ray Searcher.
        """
        mode = "max" if self._maximise else "min"
        parameters = self._parameters.copy()
        parameters[self._INITIAL_POINTS_PARAMETER] = parameters.pop(
            "num_initial_points", self._num_parallel
        )
        parameters[self._RANDOM_STATE_PARAMETER] = self._random_seed
        points_to_evaluate = parameters.pop("points_to_evaluate", None)

        sampler = optuna.samplers.CmaEsSampler(**parameters)
        searcher = self._SEARCHER_CLS(
            sampler=sampler,
            points_to_evaluate=points_to_evaluate,
            seed=self._random_seed,
        )
        res = searcher.set_search_properties(
            metric=self._metric,
            mode=mode,
            config=self._space,
        )
        if not res:
            raise ValueError("Could not set up searcher")
        return searcher
