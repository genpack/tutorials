import collections
import dataclasses
import time
import uuid
from copy import deepcopy
from pathlib import Path
from typing import Callable, Deque, Optional, Type

import pandas as pd
import pytest
from ell.env import AbstractEnv

from ell.predictions import Model, compat
from ell.predictions.distributing import LocalDistributor
from ell.predictions.utils import ParquetDatasetBatches, ParquetDatasetLoader
from tests.test_e2e.data import (
    DATASET_CATEGORICAL_ENCODINGS,
    DATASET_MLSAMPLER_INFER,
    DATASET_MLSAMPLER_OPTIMISE,
    DATASET_MLSAMPLER_TEST,
    DATASET_MLSAMPLER_TRAIN,
)

compat.env.setup_logging()


@pytest.fixture(scope="session")
def dataset_sampled_train_loader(tmp_path_factory) -> ParquetDatasetLoader:
    tmp_path = tmp_path_factory.mktemp("dataset_sampled_train")
    loader = get_dataset_loader(tmp_path, DATASET_MLSAMPLER_TRAIN)
    with loader:
        yield loader


@pytest.fixture(scope="session")
def dataset_sampled_train(
    dataset_sampled_train_loader: ParquetDatasetLoader,
) -> pd.DataFrame:
    return dataset_sampled_train_loader.load()


@pytest.fixture(scope="session")
def dataset_sampled_train_batches(
    dataset_sampled_train_loader: ParquetDatasetLoader,
) -> ParquetDatasetBatches:
    return dataset_sampled_train_loader.get_batches()


@pytest.fixture(scope="session")
def dataset_sampled_optimise_loader(tmp_path_factory) -> ParquetDatasetLoader:
    tmp_path = tmp_path_factory.mktemp("dataset_sampled_optimise")
    loader = get_dataset_loader(tmp_path, DATASET_MLSAMPLER_OPTIMISE)
    with loader:
        yield loader


@pytest.fixture(scope="session")
def dataset_sampled_optimise(
    dataset_sampled_optimise_loader: ParquetDatasetLoader,
) -> pd.DataFrame:
    return dataset_sampled_optimise_loader.load()


@pytest.fixture(scope="session")
def dataset_sampled_optimise_batches(
    dataset_sampled_optimise_loader: ParquetDatasetLoader,
) -> ParquetDatasetBatches:
    return dataset_sampled_optimise_loader.get_batches()


@pytest.fixture(scope="session")
def dataset_sampled_test_loader(tmp_path_factory) -> ParquetDatasetLoader:
    tmp_path = tmp_path_factory.mktemp("dataset_sampled_test")
    loader = get_dataset_loader(tmp_path, DATASET_MLSAMPLER_TEST)
    with loader:
        yield loader


@pytest.fixture(scope="session")
def dataset_sampled_test(
    dataset_sampled_test_loader: ParquetDatasetLoader,
) -> pd.DataFrame:
    return dataset_sampled_test_loader.load()


@pytest.fixture(scope="session")
def dataset_sampled_test_batches(
    dataset_sampled_test_loader: ParquetDatasetLoader,
) -> ParquetDatasetBatches:
    return dataset_sampled_test_loader.get_batches()


@pytest.fixture(scope="session")
def dataset_sampled_infer_loader(tmp_path_factory) -> ParquetDatasetLoader:
    tmp_path = tmp_path_factory.mktemp("dataset_sampled_infer")
    loader = get_dataset_loader(tmp_path, DATASET_MLSAMPLER_INFER)
    with loader:
        yield loader


@pytest.fixture(scope="session")
def dataset_sampled_infer(
    dataset_sampled_infer_loader: ParquetDatasetLoader,
) -> pd.DataFrame:
    return dataset_sampled_infer_loader.load()


@pytest.fixture(scope="session")
def dataset_sampled_infer_batches(
    dataset_sampled_infer_loader: ParquetDatasetLoader,
) -> ParquetDatasetBatches:
    return dataset_sampled_infer_loader.get_batches()


@dataclasses.dataclass
class MockModelRun:
    runid: Optional[str] = None
    model: Optional[Model] = None
    scores: Optional[dict] = None
    feature_importances: Optional[dict] = None
    exception: Optional[Exception] = None
    sleep_seconds: int = 0


class MockLocalDistributor(LocalDistributor):
    """A local distributor for testing.

    This distributor can be used to "simulate" distributing jobs, by adding "mock"
    moduleruns, which when distributed and collected, behave that way without
    actually having to train any models.
    """

    def __init__(
        self,
        executor_path: str,
        data_path: str,
        config_filler: Optional[Callable[[dict], dict]] = None,
        max_workers: Optional[int] = None,
        env: AbstractEnv = compat.env,
    ) -> None:
        super().__init__(executor_path, data_path, config_filler, max_workers, env)
        self._default_modulerun: Optional[MockModelRun] = None
        self._mock_moduleruns: Deque[MockModelRun] = collections.deque()

    def mock_modulerun(
        self,
        runid: Optional[str] = None,
        model: Optional[Model] = None,
        scores: Optional[dict] = None,
        feature_importances: Optional[dict] = None,
        exception: Optional[Exception] = None,
        sleep_seconds: int = 0,
    ) -> None:
        """Add a "mock" modulerun, which will be later distributed when
        distribute() is called.

        The run is added to a FIFO queue which `distribute()` consumes.

        At least one of either ``model`` or ``scores`` must be provided.
        """
        if model is None and scores is None:
            raise TypeError("Must provide one of either 'model' or 'scores'!")
        self._mock_moduleruns.append(
            MockModelRun(
                runid, model, scores, feature_importances, exception, sleep_seconds
            )
        )

    def set_default_modulerun(
        self,
        model: Optional[Model] = None,
        scores: Optional[dict] = None,
        feature_importances: Optional[dict] = None,
        exception: Optional[Exception] = None,
        sleep_seconds: int = 0,
    ) -> None:
        if model is None and scores is None:
            raise TypeError("Must provide one of either 'model' or 'scores'!")
        self._default_modulerun = MockModelRun(
            runid=None,
            model=model,
            scores=scores,
            feature_importances=feature_importances,
            exception=exception,
            sleep_seconds=sleep_seconds,
        )

    def _distribute(self, config: dict) -> str:
        if not self._mock_moduleruns or self._default_modulerun:
            raise RuntimeError("No mock moduleruns to distribute!")

        if self._mock_moduleruns:
            modulerun = self._mock_moduleruns.popleft()
        else:
            modulerun = deepcopy(self._default_modulerun)

        if modulerun.runid is not None:
            module_runid = modulerun.runid
        else:
            module_runid = str(uuid.uuid4())

        def run_mock_model() -> None:
            time.sleep(modulerun.sleep_seconds)

            if modulerun.exception is not None:
                raise modulerun.exception

            module_path = self._agentrun_path.model(module_runid)

            if modulerun.model is not None:
                modulerun.model.save(module_path)
            elif modulerun.scores is not None:
                scores_uri = module_path.file("scores.json")
                self._env.write_jsonish(uri=scores_uri, data=modulerun.scores)

            if modulerun.feature_importances is not None:
                fi_uri = module_path.file("feature_importance.json")
                self._env.write_jsonish(uri=fi_uri, data=modulerun.feature_importances)

        fut = self._executor.submit(run_mock_model)
        self._futures[fut] = module_runid

        return module_runid


@pytest.fixture()
def mock_distributor_cls() -> Type[MockLocalDistributor]:
    return MockLocalDistributor


def get_dataset_loader(tmp_path: Path, dataset: dict) -> ParquetDatasetLoader:
    df = pd.DataFrame(dataset)
    midpoint = df.shape[0] // 2
    df1: pd.DataFrame = df.iloc[:midpoint, :]
    df2: pd.DataFrame = df.iloc[midpoint:, :]

    with tmp_path.joinpath("part-00000.snappy.parquet").open("wb") as f:
        df1.to_parquet(f)

    with tmp_path.joinpath("part-00001.snappy.parquet").open("wb") as f:
        df2.to_parquet(f)

    return ParquetDatasetLoader(
        location=str(tmp_path),
        index_columns=["caseID", "eventTime"],
        batch_size=1,  # As small as possible so as to force it to be batched
        encodings=DATASET_CATEGORICAL_ENCODINGS,
    )
