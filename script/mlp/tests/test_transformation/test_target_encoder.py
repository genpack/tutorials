import pandas as pd

import category_encoders
import pytest

from ell.predictions import utils
from ell.predictions.transformation import TargetEncoder
from ell.predictions.utils import ParquetDatasetBatches


@pytest.mark.parametrize(
    "parameters",
    [
        {},
        {"smoothing": 0.9, "min_samples_leaf": 10},
        {"smoothing": 2.0, "min_samples_leaf": 200},
        {"smoothing": 1.0, "min_samples_leaf": 1000},
    ],
)
def test_target_encoder(
    dataset_sampled_train: pd.DataFrame,
    dataset_sampled_infer: pd.DataFrame,
    parameters: dict,
):
    encoder = TargetEncoder(
        config=dict(
            input=dict(
                include=dict(
                    categoricals=True,
                    target=True,
                )
            ),
            parameters=parameters,
        )
    )
    ref_encoder = category_encoders.TargetEncoder(**parameters)

    cat_cols = utils.get_categorical_cols(dataset_sampled_train)

    X_train = dataset_sampled_train.filter(cat_cols)
    y_train = dataset_sampled_train["label"]

    expected_train_df = ref_encoder.fit_transform(X_train, y_train)
    actual_train_df = encoder.fit_transform(dataset_sampled_train)
    pd.testing.assert_frame_equal(actual_train_df, expected_train_df)

    X_infer = dataset_sampled_infer.filter(cat_cols)

    expected_infer_df = ref_encoder.transform(X_infer)
    actual_infer_df = encoder.transform(dataset_sampled_infer)
    pd.testing.assert_frame_equal(actual_infer_df, expected_infer_df)


@pytest.mark.parametrize(
    "parameters",
    [
        {},
        {"smoothing": 0.9, "min_samples_leaf": 10},
        {"smoothing": 2.0, "min_samples_leaf": 200},
        {"smoothing": 1.0, "min_samples_leaf": 1000},
    ],
)
def test_target_encoder_batched(
    dataset_sampled_train_batches: ParquetDatasetBatches,
    dataset_sampled_infer_batches: ParquetDatasetBatches,
    parameters: dict,
):
    encoder = TargetEncoder(
        config=dict(
            input=dict(
                include=dict(
                    categoricals=True,
                    target=True,
                )
            ),
            parameters=parameters,
        )
    )
    ref_encoder = category_encoders.TargetEncoder(**parameters)

    dataset_sampled_train = dataset_sampled_train_batches[:]
    cat_cols = utils.get_categorical_cols(dataset_sampled_train)

    X_train = dataset_sampled_train.filter(cat_cols)
    y_train = dataset_sampled_train["label"]

    expected_train_df = ref_encoder.fit_transform(X_train, y_train)
    actual_train_df = encoder.fit_transform(dataset_sampled_train_batches)[:]
    pd.testing.assert_frame_equal(actual_train_df, expected_train_df)

    dataset_sampled_infer = dataset_sampled_infer_batches[:]
    X_infer = dataset_sampled_infer.filter(cat_cols)

    expected_infer_df = ref_encoder.transform(X_infer)
    actual_infer_df = encoder.transform(dataset_sampled_infer_batches)[:]
    pd.testing.assert_frame_equal(actual_infer_df, expected_infer_df)
