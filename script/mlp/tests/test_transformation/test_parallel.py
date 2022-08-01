import pandas as pd

from ell.predictions.transformation import Parallel


def test_parallel_rejoining():
    indf = pd.DataFrame([(1, 1)], columns=["a", "b"])
    transformer = Parallel(
        config=dict(
            steps=[
                dict(
                    type="UnitTransformer",
                    input=dict(
                        include=["a"],
                    ),
                ),
                dict(
                    type="UnitTransformer",
                    input=dict(
                        include=["b"],
                    ),
                ),
            ]
        )
    )

    pd.testing.assert_frame_equal(transformer.transform(indf), indf)


def test_remainder():
    indf = pd.DataFrame([(1, 1)], columns=["a", "b"])
    transformer = Parallel(
        config=dict(
            steps=[
                dict(
                    type="UnitTransformer",
                    input=dict(
                        include=["a"],
                    ),
                ),
                dict(
                    type="UnitTransformer",
                    input=dict(
                        remainder=True,
                    ),
                ),
            ]
        )
    )

    pd.testing.assert_frame_equal(transformer.fit_transform(indf), indf)
