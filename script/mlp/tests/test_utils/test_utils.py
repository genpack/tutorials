import numpy as np
import pandas as pd

from ell.predictions.utils import get_predictions_glue_schema

# noinspection PyProtectedMember
from ell.predictions.utils.utils import PREDICTIONS_GLUE_SCHEMA


def test_get_train_glue_schema():
    expected_schema = PREDICTIONS_GLUE_SCHEMA
    expected_schema["category"] = "boolean"
    expected_schema["label"] = "boolean"
    cats_df = pd.DataFrame(columns=["category", "label"], dtype=bool)
    assert expected_schema == get_predictions_glue_schema(cats_df)

    expected_schema["category"] = "float"
    expected_schema["label"] = "float"
    cats_df = pd.DataFrame(columns=["category", "label"], dtype=np.float16)
    assert expected_schema == get_predictions_glue_schema(cats_df)

    expected_schema["category"] = "float"
    expected_schema["label"] = "float"
    cats_df = pd.DataFrame(columns=["category", "label"], dtype=np.float32)
    assert expected_schema == get_predictions_glue_schema(cats_df)

    expected_schema["category"] = "double"
    expected_schema["label"] = "double"
    cats_df = pd.DataFrame(columns=["category", "label"], dtype=np.float64)
    assert expected_schema == get_predictions_glue_schema(cats_df)

    expected_schema["category"] = "tinyint"
    expected_schema["label"] = "tinyint"
    cats_df = pd.DataFrame(columns=["category", "label"], dtype=np.int8)
    assert expected_schema == get_predictions_glue_schema(cats_df)

    expected_schema["category"] = "smallint"
    expected_schema["label"] = "smallint"
    cats_df = pd.DataFrame(columns=["category", "label"], dtype=np.int16)
    assert expected_schema == get_predictions_glue_schema(cats_df)

    expected_schema["category"] = "int"
    expected_schema["label"] = "int"
    cats_df = pd.DataFrame(columns=["category", "label"], dtype=np.int32)
    assert expected_schema == get_predictions_glue_schema(cats_df)

    expected_schema["category"] = "bigint"
    expected_schema["label"] = "bigint"
    cats_df = pd.DataFrame(columns=["category", "label"], dtype=np.int64)
    assert expected_schema == get_predictions_glue_schema(cats_df)


def test_get_infer_glue_schema():
    expected_schema = PREDICTIONS_GLUE_SCHEMA
    expected_schema["category"] = "boolean"
    expected_schema["label"] = "int"
    cats_df = pd.DataFrame(columns=["category"], dtype=bool)
    assert expected_schema == get_predictions_glue_schema(cats_df)

    cats_df = pd.DataFrame()
    assert expected_schema == get_predictions_glue_schema(cats_df)
