import abc
import logging
from copy import deepcopy
from typing import List, Optional, TYPE_CHECKING

from ell.predictions.classification import AbstractClassifier
from ell.predictions.distributing import AbstractDistributor

if TYPE_CHECKING:
    from ell.predictions import Model

LOGGER = logging.getLogger(__name__)


class AbstractAverager(AbstractClassifier, abc.ABC):

    DEFAULT_PARAMETERS = dict(
        num_models=[1],
        seed=0,
        normalize=True,
    )
    models: List["Model"]

    def __init__(self, config: dict) -> None:
        super().__init__(config)
        if not config.get("models"):
            raise ValueError("models list must not be empty")
        models_cfg_list = config["models"]

        self.model_cfgs = []

        for i, model_cfg in enumerate(models_cfg_list):

            if self.parameters.get("num_models"):
                num_models = self.parameters["num_models"]
            else:
                num_models = [1]

            for n in range(0, num_models[i]):
                new_cfg = deepcopy(model_cfg)
                model_parameters = new_cfg["classifier"].setdefault("parameters", {})

                if self.parameters.get("seed"):
                    if isinstance(self.parameters["seed"], int):
                        model_parameters["seed"] = self.parameters["seed"]
                    else:
                        seed_idx = (i + n) % len(self.parameters["seed"])
                        model_parameters["seed"] = self.parameters["seed"][seed_idx]
                    LOGGER.debug(
                        "Setting seed %s for model %s number %s",
                        model_parameters["seed"],
                        i,
                        n,
                    )

                self.model_cfgs.append(new_cfg)

        self.reset()

    def reset(self):
        self.models = []

    def fit(self, dataset: Optional, *, distributor: Optional[AbstractDistributor] = None) -> None:
        if distributor is None and dataset is None:
            raise ValueError(
                "When fitting an ensembler, at least one of dataset or distributor must be "
                "provided"
            )
        if distributor is not None:
            # Fit all models "asynchronously" with the distributor
            runids = list(map(distributor.distribute, self.model_cfgs))
            self.models.extend(distributor.collect_modules(runids).values())
        else:
            # Fit models in sequence locally
            # Local import to avoid circular imports
            from ell.predictions import Model

            for model_cfg in self.model_cfgs:
                model = Model.from_config(model_cfg)
                model.fit(dataset)
                self.models.append(model)
