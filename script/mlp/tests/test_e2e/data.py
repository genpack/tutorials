import datetime
import random
import string

import numpy as np
from sklearn.datasets import make_classification

random.seed(42)


def _generate_predictions(data):
    dataset = [
        {
            "caseID": _["caseID"],
            "eventTime": _["eventTime"],  # eventtime, column of arbitray timestamps
            "probability": random.randint(0, 1000)
            / 1000,  # label column of either 0 or 1
            "tte": random.randint(0, 100),  # column full of full integers
            "category": random.randint(0, 1),  # column full of floats
        }
        for _ in data
    ]

    return dataset


# def _generate_dataset(rows=1000, include_target=True):
def _generate_dataset(rows=15000, include_target=True):
    X1, y1 = make_classification(
        n_samples=rows,
        n_features=3,
        n_informative=2,
        n_redundant=0,
        n_repeated=0,
        n_classes=2,
        n_clusters_per_class=2,
        class_sep=1.2,
        flip_y=0,
        weights=[0.9, 0.1],
        random_state=42,
    )

    colC = np.random.choice([0, 1, 2, 3], size=15000, p=[0.01, 0.2, 0.4, 0.39])

    dataset = [
        {
            # "caseID": str(uuid.uuid4()),
            # "eventTime": datetime.date.today()
            # + datetime.timedelta(days=random.randint(0, 1000)),
            "caseID": "".join(
                random.choices(string.ascii_uppercase + string.digits, k=5)
            ),
            "eventTime": datetime.date(2020, 1, 1)
            + datetime.timedelta(days=random.randint(0, 1000)),
            # column of arbitray timestamps
            "label": y1[jj],  # label column of either 0 or 1
            "colA": random.randint(0, 100),  # column full of full integers
            "colB": X1[jj, 0],  # column full of floats
            "colC": colC[jj],  # column of 4 categories
            "colD": random.randint(0, 100),  # column full of full integers
            "colE": X1[jj, 1],  # column full of floats
            "colF": int(random.randrange(0, 4, 1)),  # column of 4 categories
            "colG": random.randint(0, 100),  # column full of full integers
            "colH": X1[jj, 2],  # column full of floats
            "colI": int(random.randrange(0, 4, 1)),  # column of 4 categories
        }
        for jj in range(rows)
    ]

    if not include_target:
        [i.pop("label") for i in dataset]

    return dataset


DATASET_CATEGORICAL_ENCODINGS = {
    "colC": {"0": "F", "1": "M", "2": "__unknown", "3": "Missing"},
    # "nonexistent_categorical": {"0": 0, "1": 1},
}

DATASET_MLMAPPER = _generate_dataset(include_target=False)

DATASET_DESCRIBER = _generate_dataset(rows=2, include_target=False)

DATASET_MLSAMPLER_TRAIN = _generate_dataset()

DATASET_MLSAMPLER_TEST = _generate_dataset()

DATASET_MLSAMPLER_OPTIMISE = _generate_dataset()

DATASET_MLSAMPLER_PREDICT = _generate_predictions(data=DATASET_MLSAMPLER_OPTIMISE)

DATASET_MLSAMPLER_INFER = _generate_dataset(rows=5)

DATASET_MLSAMPLER_PREDICT_INFER = _generate_predictions(data=DATASET_MLSAMPLER_INFER)

# TRAIN_LABEL_2 = _generate_dataset(label_col='label_2')
#
# TEST_LABEL_2 = _generate_dataset(label_col='label_2')
#
# OPTIMISE_LABEL_2 = _generate_dataset(label_col='label_2')

# PREDICT_LABEL_2 = _generate_predictions(data=DATASET_MLSAMPLER_OPTIMISE, label_col='label_2')
