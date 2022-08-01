import logging

from .ray_hpo_abc import RayAbstractTuner

try:
    from ray import tune
    from ray.tune.suggest.hyperopt import HyperOptSearch
except ModuleNotFoundError:
    tune = None
    HyperOptSearch = None

LOGGER = logging.getLogger(__name__)


class TreeOfParzen(RayAbstractTuner):
    """Class for Tree of Parzen optimisation

    This HPO algorithm makes use of :class:`ray.tune.suggest.hyperopt.HyperOptSearch`
    """

    #: By default, TPE eagerly collects and submits models.
    DEFAULT_SUBMISSION_STRATEGY = "eager"

    _SEARCHER_CLS = HyperOptSearch
    _INITIAL_POINTS_PARAMETER = "n_initial_points"
    _RANDOM_STATE_PARAMETER = "random_state_seed"
