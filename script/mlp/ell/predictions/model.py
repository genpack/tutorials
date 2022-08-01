import logging
import pickle
from typing import Any, Dict, List, Optional

from ell.env import AbstractEnv

from . import compat, utils
from .classification import AbstractClassifier
from .ensembling import AbstractAverager
from .distributing import AbstractDistributor
from .transformation import AbstractTransformer, UnitTransformer

LOGGER = logging.getLogger(__name__)


class Model:
    """A prediction model.

    A model (currently) is composed of:

    - An estimator (more specifically, a classifier), and
    - A transformer.

    In the past, the predictions library relied very heavily on the
    :class:`AbstractClassifier` class, as it had the responsibility of not
    only being a classifier, but also running transformers. This class
    aims to take that responsibility itself, so classifiers can just be
    classifiers.

    By default, the transformer is just a simple,
    :class:`UnitTransformer`, which makes the model behave just like the
    classifier without any transformers.

    Attributes:
        estimator (:class:`AbstractClassifier`): The classifier which makes
            predictions.
        transformer (:class:`AbstractTransformer`): The transformer which
            processes the dataset prior to fitting the estimator or
            making predictions.
        features (Optional[List[:class:`str`]]): The (untransformed)
            features which this model is or will be fitted to.
        labels (List[:class:`str`]): The (untransformed)
            label column(s) which determine the target of the
            classifier. Defaults to ``['label']``. One situation where
            you might override this value is if you are defining a
            custom label column from TTE, or other uncensored label
            columns.

    """

    def __init__(
        self,
        estimator: AbstractClassifier,
        transformer: AbstractTransformer = UnitTransformer(),
        features: Optional[List[str]] = None,
        labels: Optional[List[str]] = None,
    ) -> None:
        self.estimator = estimator
        self.transformer = transformer
        self.features = features
        self.labels = labels or ["label"]

    @classmethod
    def from_config(cls, config: Dict[str, Any]) -> "Model":
        """Create a model from a config.

        With respect to the full config submitted to the EppAPI API,
        this should be the section beneath the 'model' key.
        """
        config = utils.resolve_param_references(config)

        classifier_cfg = config["classifier"]
        estimator = AbstractClassifier.from_config(classifier_cfg)

        transformer_cfg = config.get("transformer")
        if transformer_cfg:
            transformer = AbstractTransformer.from_config(
                transformer_cfg, target=estimator.target
            )
        else:
            transformer = UnitTransformer(target=estimator.target)

        return cls(
            estimator,
            transformer,
            features=config.get("features"),
            labels=config.get("labels", ["label"]),
        )

    def fit(self, dataset, *, distributor: Optional[AbstractDistributor] = None) -> None:
        """Fit the model to the given dataset.

        A distributor may be provided if the :attr:`~Model.estimator` is an
        :class:`AbstractAverager` and you wish for this ensembler to distribute
        jobs.
        """
        if self.features is None:
            self.features = utils.get_features(dataset, labels=self.labels)

        dataset = self.transformer.fit_transform(dataset)
        if isinstance(self.estimator, AbstractAverager) and distributor is not None:
            self.estimator.fit(dataset, distributor=distributor)
        else:
            self.estimator.fit(dataset)

    def optimise_threshold(self, dataset, **kwargs) -> None:
        """Optimise the decision boundary of the model with the given
        dataset.

        Args:
            dataset: The dataset to use as a reference for optimising
                the decision boundary.
            **kwargs: Keyword arguments passed onto
                :meth:`AbstractClassifier.optimise_threshold`.
        """
        dataset = self.transformer.transform(dataset)
        self.estimator.optimise_threshold(dataset, **kwargs)

    def predict(self, dataset, *, return_labels: bool = False):
        """Make predictions on the given input samples.

        Args:
            dataset: The dataset of input samples.
            return_labels: Passed onto :meth:`AbstractClassifier.predict`.

        Returns:
            The predictions from :meth:`AbstractClassifier.predict`.

        """
        dataset = self.transformer.transform(dataset)
        return self.estimator.predict(dataset, return_labels=return_labels)

    def score(self, dataset):
        """Evaluate the model's performance on the given dataset."""
        dataset = self.transformer.transform(dataset)
        return self.estimator.score(dataset)

    def save(self, folder_uri: str, env: AbstractEnv = compat.env) -> None:
        """Persist the model and any diagnostics.

        Args:
            folder_uri (:class:`str`): URI to the folder where the model
                (and any diagnostics) will be persisted. Generally, the
                pickled model will be written to ``model/model.pkl``
                within this path, and (if available) feature importance
                will be written to ``feature_importance.json``.
            env (:class:`AbstractEnv`): Environment to use for I/O.

        """
        folder_uri = utils.ensure_uri(folder_uri, is_folder=True)
        self.estimator.save_diagnostics(folder_uri, env)

        model_uri = folder_uri.folder("model").file("model.pkl")
        LOGGER.info("Persisting model to %r", model_uri)

        filesystem = env.get_fs_for_uri(model_uri)
        with filesystem.open(model_uri, "wb") as f:
            pickle.dump(self, f)

        LOGGER.info("Model persisted")

    def __repr__(self) -> str:
        return (
            f"{self.__class__.__name__}(estimator={self.estimator!r}, "
            f"transformer={self.transformer!r})"
        )

    def __str__(self) -> str:
        return repr(self)
