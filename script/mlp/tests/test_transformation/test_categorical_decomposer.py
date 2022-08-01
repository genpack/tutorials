import pandas as pd
import scipy.sparse
from pandas import SparseDtype

from ell.predictions.transformation import Dummifier


def test_column_names():
    in_df = pd.DataFrame([(1, 1, 1, 1, 1)], columns=["a", "b", "c", "d", "e"]).astype(
        {
            "a": pd.CategoricalDtype([1, 2, 3]),
            "b": "int32",
            "c": pd.CategoricalDtype([1, 2]),
            "d": "float32",
            "e": pd.CategoricalDtype([0, 1, 2, -9999]),
        }
    )

    # Check that the default passes through binary categoricals unchanged
    transformer = Dummifier(
        config=dict(
            input=dict(
                include=dict(
                    categoricals=True,
                ),
                exclude=["e"],
            )
        )
    )
    out_df = transformer.fit_transform(in_df)
    assert list(out_df.columns) == ["a_1", "a_2", "a_3", "c"]

    # Test categoricals with -9999 as a category
    transformer = Dummifier(
        config=dict(
            input=dict(
                include=["e"],
            )
        )
    )
    out_df = transformer.fit_transform(in_df)
    assert list(out_df.columns) == ["e_0", "e_1", "e_2", "e_9999"]


def test_categorical_dummifier():
    in_df = pd.DataFrame(
        {
            "gender": pd.Categorical([0, 1, -9999, 1]),
            "city": pd.Categorical(
                [1, -9999, 3, 7],
                categories=[1, 2, 3, 4, 5, 6, 7, -9999],
            ),
            "postcode": pd.Categorical([2000, -9999, 301239, 399]),
        }
    )

    transformer = Dummifier()
    out_df = transformer.fit_transform(in_df)

    expected_df = pd.DataFrame(
        {
            "city_1": [1, 0, 0, 0],
            "city_2": [0, 0, 0, 0],
            "city_3": [0, 0, 1, 0],
            "city_4": [0, 0, 0, 0],
            "city_5": [0, 0, 0, 0],
            "city_6": [0, 0, 0, 0],
            "city_7": [0, 0, 0, 1],
            "city_9999": [0, 1, 0, 0],
            "gender_0": [1, 0, 0, 0],
            "gender_1": [0, 1, 0, 1],
            "gender_9999": [0, 0, 1, 0],
            "postcode_2000": [1, 0, 0, 0],
            "postcode_301239": [0, 0, 1, 0],
            "postcode_399": [0, 0, 0, 1],
            "postcode_9999": [0, 1, 0, 0],
        },
        dtype=SparseDtype("bool"),
    )

    pd.testing.assert_frame_equal(out_df, expected_df)
