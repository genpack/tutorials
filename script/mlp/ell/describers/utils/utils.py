__all__ = [
    "generate_samples",
    "inbox",
    "scores_meet_threshold",
    "update_container_meta",
    "predict_probabilities",
    "predict_categories",
]

import logging
import os
from datetime import datetime
from typing import Optional, TYPE_CHECKING

import numpy as np
import pandas as pd
from lime import lime_tabular
from sklearn.compose import ColumnTransformer
from sklearn.neighbors import NearestNeighbors
from sklearn.preprocessing import OneHotEncoder, RobustScaler

from ell.describers import compat

if TYPE_CHECKING:
    from ell.predictions import Model

LOGGER = logging.getLogger(__name__)

jobs_table = compat.env.boto3_session.resource("dynamodb").Table("DescriberJobs")


def generate_samples(
    dataset,
    row,
    encodings,
    num_samples=1000,
    kernel_width=None,
    verbose=False,
    exclude_categoricals=None,
    scale=5,
    random_state=None,
    how="knn",
    features=None,
):

    """
    Given a row, we want to define a locality around that row where we
    fit and test the goodness of our explanation via various metrics. To do this, we
    create a set of datapoints that we call the local area. Sampled from the
    area nearby.

    Currently two implementations exist. We use LIME's internal algorithm for generating samples, which is
    done by perturbing the data via a (0, 1) normal distribution. This happens when how='perturb'.

    When how='knn', we don't perturb, we use the num_samples nearest neighbours of our point for our dataset. This
    is our preferred method, as it is fast and generates relevant counterfactuals, with no possibility of a point
    where "numChildren = -4.5"

    :param exclude_categoricals: When decomposing, features to not dummify, to avoid high dimensionality. For example, a postcode or suburb feature
    :param features: Features to use for the knn. Defaults to None, where all features will be used
    :param how: Choice between 'knn' and 'perturb', defaults to knn. If knn, choose num_samples closest samples to our row. If perturb, generating num_samples by perturbing our row
    :param scale: How to scale the generated samples. Higher number means further away from row, default=1
    :param dataset: The data that we want to generate more samples from
    :param row: The row we want to generate samples around
    :param encodings: Encoding dict associated with the dataset
    :param num_samples: Number of samples to generate
    :param kernel_width: LIME kernel_width parameter
    :param verbose: Verbosity switch
    :param random_state: Random state
    :returns: A dataframe of num_samples rows drawn from the local area around our rows
    """

    LOGGER.info("how: %s", how)

    if isinstance(row, pd.Series):
        row = row.to_frame().transpose()

    if how == "perturb":
        X = _generate_samples_pertub(
            dataset,
            row,
            encodings,
            num_samples,
            kernel_width,
            verbose,
            scale,
            random_state,
        )
    elif how == "knn":
        X = _generate_samples_knn(
            dataset, row, num_samples, encodings, features, exclude_categoricals
        )
    else:
        LOGGER.error("Unknown method of generating samples: {}".format(how))
        raise ValueError()

    return X


def _generate_samples_pertub(
    dataset,
    row,
    encodings,
    num_samples=1000,
    kernel_width=None,
    verbose=False,
    scale=5,
    random_state=None,
):
    """
    Generates samples via LIME pertubation
    Assumes each dimension is weighted equally

    :param dataset: dataframe -  entire dataset
    :param row: dataframe -  row for explanation
    :param num_samples: int - number of nearby samples to output
    :returns: dataframe - output dataframe
    """

    from .wrapper_lime import LimeDescriber

    our_lime_instance = LimeDescriber(
        workspace=None,
        run=None,
        X=dataset,
        encodings=encodings,
        predict_categories_fn=None,
        predict_probabilities_fn=None,
    )

    categorical_positions, categorical_names = our_lime_instance.get_categoricals(
        dataset
    )

    native_lime_instance = lime_tabular.LimeTabularDescriber(
        dataset.values,
        mode="classification",
        feature_names=dataset.columns,
        categorical_features=categorical_positions,
        categorical_names=categorical_names,
        kernel_width=kernel_width,
        # kernel=None,
        verbose=verbose,
        class_names=None,
        feature_selection="auto",
        discretize_continuous=False,
        sample_around_instance=True,
        random_state=random_state,
    )

    # print("Scale: ", native_lime_instance.scaler.scale_)
    native_lime_instance.scaler.scale_ = scale

    # The difference here is that data has the categorical features encoded with a 0
    # if they are different to our row, or a 1 in they are the same.
    # While inverse has them as categorical, as in the original
    # noinspection PyProtectedMember
    data, inverse = native_lime_instance._LimeTabularDescriber__data_inverse(
        row.values[0], num_samples=num_samples
    )

    inverse = pd.DataFrame(inverse)
    inverse.columns = dataset.columns
    X = inverse

    return X


def _generate_samples_knn(
    dataset,
    row,
    num_samples,
    categoricals=None,
    features=None,
    exclude_categoricals=None,
):
    """
    Generates samples from nearest neighbours.
    Fits a KNN on the dataset and finds num_samples close to the row
    Assumes each dimension is weighted equally
    #TODO check how slow this is - how it affects overall performance

    :param dataset: dataframe -  entire dataset
    :param row: dataframe -  row for explanation
    :param num_samples: int - number of nearby samples to output
    :returns: dataframe - output dataframe
    """

    exclude_categoricals = exclude_categoricals or []

    if categoricals is None:
        categoricals = []
    else:
        categoricals = [c for c in list(categoricals) if c not in exclude_categoricals]

    LOGGER.info("categoricals: %s", categoricals)
    LOGGER.info("dataset: %s", dataset)

    X = dataset

    LOGGER.info("features: %s", features)
    if isinstance(features, list) and len(features) > 0:
        row = row[features]
        dataset = dataset[features]
        LOGGER.info("row and dataset filtered for features as listed above.")

    row = row.replace([-9999, -9999.0], 9999)
    dataset = dataset.replace([-9999, -9999.0], 9999)

    assert dataset.isnull().sum().sum() == 0, "Describer passed dataset with na values"
    LOGGER.info("asserted, no NaN or inf values in dataset")

    concated = pd.concat([dataset, row], axis=0)

    sorted_columns = sorted(concated.columns)
    concated = concated[sorted_columns]
    dataset = dataset[sorted_columns]
    row = row[sorted_columns]
    LOGGER.info("all columns sorted for concated, dataset and row")

    categoricals_mask = [bool(feature in categoricals) for feature in dataset.columns]

    dummifier = ColumnTransformer(
        transformers=[("OneHot", OneHotEncoder(), categoricals_mask)],
        remainder="passthrough",
    )

    scaler = RobustScaler(with_centering=False)

    assert concated.isnull().sum().sum() == 0, "Describer passed dataset with na values"
    LOGGER.debug(
        "minimum values: %s",
        concated[[c for c in categoricals if c in concated.columns]].min().to_json(),
    )

    dummifier.fit(concated)
    dummified_dataset = dummifier.transform(dataset)
    dummified_row = dummifier.transform(row)

    LOGGER.debug("Dataset after decomposing in utils: {}".format(dummified_dataset))
    LOGGER.debug("Row after decomposing in utils: {}".format(dummified_row))

    scaler.fit(dummified_dataset)
    scaled_dataset = scaler.transform(dummified_dataset)
    scaled_row = scaler.transform(dummified_row)

    knn = NearestNeighbors(n_neighbors=num_samples)
    knn.fit(scaled_dataset)

    indices = list(knn.kneighbors(scaled_row)[1][0])
    X = X.iloc[indices]

    LOGGER.debug("Returning knn generated dataset {}".format(X))

    return X


def inbox(row, box):
    """Determines if row is in box

    Gower is a similarity measure for categorical, boolean and numerical mixed
    data.


    Parameters
    ----------
    row : array-like, or pandas.DataFrame, row of interest

    box : dict, containing the boundaries of the box


    Returns
    -------
    True/False: bool

    """

    for feature in box.keys():
        if box[feature]["upper"] is not None:
            if row[feature].values[0] > box[feature]["upper"]:
                return False
        if box[feature]["lower"] is not None:
            if row[feature].values[0] < box[feature]["lower"]:
                return False
    return True


def scores_meet_threshold(scores: dict, score_thresholds: dict) -> bool:
    """Returns True if all scores in the dictionary meet the specified
    (minimum) thresholds.
    """
    meets_threshold = True
    for category, cutpoint in score_thresholds.items():
        if scores[category] < cutpoint:
            LOGGER.debug(
                "Score category %r (value %s) does not meet cutpoint %s",
                category,
                scores[category],
                cutpoint,
            )
            meets_threshold = False

    return meets_threshold


def update_container_meta(
    state: Optional[str] = None,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
):
    fields = {}
    if state is not None:
        fields["state"] = state
    if start_time is not None:
        fields["start"] = f"{start_time.isoformat(timespec='milliseconds')}Z"
    if end_time is not None:
        fields["end"] = f"{end_time.isoformat(timespec='milliseconds')}Z"

    LOGGER.info("Updating meta in DynamoDB table")
    kwargs = dict(
        Key=dict(
            runid=os.environ["runid"],
            attempt_partition_id=(
                f"attempt={compat.ATTEMPT_NUMBER:02}_partition={compat.PARTITION_ID:02}"
            ),
        ),
        UpdateExpression="SET " + ", ".join(f"#{key} = :{key}" for key in fields),
        ExpressionAttributeNames={f"#{key}": key for key in fields},
        ExpressionAttributeValues={f":{key}": value for key, value in fields.items()},
    )
    LOGGER.debug("dynamodb:UpdateItem args:", extra={"data": kwargs})
    response = jobs_table.update_item(**kwargs)
    LOGGER.debug("dynamodb:UpdateItem response:", extra={"data": response})


def predict_probabilities(model: "Model", X: pd.DataFrame) -> np.ndarray:
    """Use a model to predict the probabilities of some samples.

    The model must only use Pandas-based estimators and transformers.w

    Probabilities are returned in a 2-dimensional numpy array with shape
    (n_samples, n_classes).

    This function is only really used for passing into the
    :class:`ExplanationEvaluator` as the
    ``predict_or_get_probabilities`` function. To do so, it should be
    made :class:`~functools.partial` with the ``model`` already passed
    in.

    Args:
        model: The model to use for predicting.
        X: Dataframe of input samples.

    Returns:
         The class probabilities of each sample.

    """
    proba_df, cats_df = model.predict(X)
    return proba_df.to_numpy(dtype="float64")


def predict_categories(model: "Model", X: pd.DataFrame) -> np.ndarray:
    """Use a model to predict the class of some samples.

    The model must only use Pandas-based estimators and transformers.

    Categories are returned in a 2-dimensional numpy array with shape
    (n_samples, 1).

    This function is only really used for passing into the
    :class:`ExplanationEvaluator` as the
    ``predict_or_get_categories`` function. To do so, it should be
    made :class:`~functools.partial` with the ``model`` already passed
    in.

    Args:
        model: The model to use for predicting.
        X: Dataframe of input samples.

    Returns:
         The predicted class of each sample.

    """
    proba_df, cats_df = model.predict(X)
    return cats_df.category.to_numpy(dtype="int32")
