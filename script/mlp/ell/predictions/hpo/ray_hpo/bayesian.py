import logging
from copy import deepcopy
from typing import Dict, Any, Tuple, Union

from .ray_hpo_abc import RayAbstractTuner

try:
    from ray import tune
    from ray.tune.suggest.bayesopt import BayesOptSearch
except ModuleNotFoundError:
    tune = None
    BayesOptSearch = None

LOGGER = logging.getLogger(__name__)


class Bayesian(RayAbstractTuner):
    """Class for Bayesian optimisation

    This HPO algorithm makes use of :class:`ray.tune.suggest.bayesopt.BayesOptSearch`
    """

    #: By default, Bayesian optimisation makes use of batches, so each batch of
    #: models is submitted only when all models from the previous batch have completed
    DEFAULT_SUBMISSION_STRATEGY = "batch"

    #: Bayesian optimisation does not support anything other
    #: than uniform distributions over integers, floats, or categoricals.
    SUPPORTED_DISTRIBUTIONS = frozenset(
        {
            "uniform",
            "randint",
            "choice",
        }
    )
    _SEARCHER_CLS = BayesOptSearch
    _INITIAL_POINTS_PARAMETER = "random_search_steps"
    _RANDOM_STATE_PARAMETER = "random_state"

    @classmethod
    def _configure_search_space(
        cls, space_spec: Dict[str, Dict[str, Any]]
    ) -> Tuple[Dict[str, "tune.sample.Domain"], Dict[str, Any]]:
        """Configure the search space for Bayesian Optimisation

        Since Bayesian Optimisation by default does not support anything other than
        uniform floats, we need to make more extensive use of interpretation arguments.
        For categoricals, integers, and distributions with a ``step``, we store the
        additional information required to recreate these distributions inside the
        interpretation arguments.

        Args:
            space_spec: The space specification located at config["hpo"]["space"]

        Returns:
            tuple containing the search space as the first element, and a dictionary
            of interpretation arguments as the second element. The interpretation args
            contains the following items:

            - choice_map (Dict[str, Dict[int, Any]): A dictionary that maps parameters
              to an integer encoding of the choices. The uniform float is rounded to the
              nearest integer, and then the corresponding choice is looked up in the map.
            - step_map (Dict[str, Union[float, int]): A dictionary that maps
              parameters to their step value. The uniform float is rounded to the nearest
              whole multiple of this step value. The datatype of the interpreted
              parameter depends on the data type of the step.

            The items in the interpretation arguments dict are passed as kwargs to
            :meth:`~_interpret_parameters`.
        """
        choice_map = {}
        step_map = {}
        space = {}
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
                choice_map[parameter] = {
                    i: val for i, val in enumerate(spec["choices"])
                }
                space[parameter] = tune.uniform(lower=0, upper=len(spec["choices"]) - 1)

            else:
                if distribution_name != "uniform" or spec.get("step"):
                    step_map[parameter] = spec.get("step", 1)

                space[parameter] = tune.uniform(
                    lower=min(spec["range"]), upper=max(spec["range"])
                )

        interpretation_args = dict(choice_map=choice_map, step_map=step_map)
        return space, interpretation_args

    @staticmethod
    def _interpret_parameters(
        parameters: Dict[str, Any],
        *,
        choice_map: [Dict[str, Dict[int, Any]]] = None,
        step_map: [Dict[str, Union[float, int]]] = None,
        **kwargs,
    ) -> Dict[str, Any]:
        """Converts parameters accepted by BayesianOptimisation into forms accepted by model

        The interpretations of all base classes are performed first, then two more are
        performed.

        #. All choice distributions are mapped to the correct value.
        #. All distributions with a ``step`` are rounded to the correct value. The final
           datatype of the parameter depends on the type of the step.

        Args:
            parameters: A dictionary of parameters to interpret
            choice_map: A dictionary that maps parameters to an integer encoding of the
                choices. The uniform float is rounded to the nearest integer, and then
                the corresponding choice is looked up in the map.
            **kwargs: Any additional arguments that are required to interpret the
                provided parameters. These vary per HPO algorithm.

        Returns:
            A dictionary mapping parameter names to interpreted values.
        """
        if choice_map is None or step_map is None:
            raise ValueError("Both choice_map and step_map are required kwargs")

        updated_parameters = {}
        for name, value in parameters.items():
            if name in step_map:
                step = step_map[name]
                value = step * round(value / step)
            if name in choice_map:
                categories = choice_map[name]
                value = categories[round(value)]

            updated_parameters[name] = value

        if "eta_k" in updated_parameters:
            eta_k = updated_parameters.pop("eta_k")
            n_estimators = updated_parameters["n_estimators"]
            updated_parameters["eta"] = min(eta_k, n_estimators) / n_estimators

        return updated_parameters
