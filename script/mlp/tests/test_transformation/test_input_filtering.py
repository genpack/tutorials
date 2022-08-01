import pandas as pd

from ell.predictions.transformation import UnitTransformer


def test_explicit_include():
    indf = pd.DataFrame(columns=["a", "b", "c"])

    transformer = UnitTransformer(config=dict(input=dict(include=["c"])))
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["c"]

    transformer = UnitTransformer(config=dict(input=dict(include=["c", "b"])))
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["c", "b"]

    # The above methods are really just a shorthand for the following
    transformer = UnitTransformer(
        config=dict(input=dict(include={"columns": ["a", "c"]}))
    )
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["a", "c"]


def test_explicit_exclude():
    indf = pd.DataFrame(columns=["a", "b", "c"])

    transformer = UnitTransformer(config=dict(input=dict(exclude=["c"])))
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["a", "b"]

    transformer = UnitTransformer(config=dict(input=dict(exclude=["c", "b"])))
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["a"]

    # The above methods are really just a shorthand for the following
    transformer = UnitTransformer(
        config=dict(input=dict(exclude=dict(columns=["a", "c"])))
    )
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["b"]


def test_filtering_by_dtype():
    indf = pd.DataFrame(columns=["a", "b", "c", "d", "e"]).astype(
        {
            "a": pd.CategoricalDtype([1, 2, 3]),
            "b": "int32",
            "c": pd.CategoricalDtype([1, 2, 3, 4, 5]),
            "d": "float32",
            "e": "bool",
        }
    )

    # All categoricals
    transformer = UnitTransformer(
        config=dict(input=dict(include=dict(categoricals=True)))
    )
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["a", "c"]

    # Categoricals with max_cardinality of 5
    transformer = UnitTransformer(
        config=dict(input=dict(include=dict(categoricals=dict(max_cardinality=5))))
    )
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["a", "c"]

    # Categoricals with max_cardinality of 4
    transformer = UnitTransformer(
        config=dict(input=dict(include=dict(categoricals=dict(max_cardinality=4))))
    )
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["a"]

    # All numericals
    transformer = UnitTransformer(
        config=dict(input=dict(include=dict(numericals=True)))
    )
    outdf = transformer.transform(indf)
    assert list(outdf.columns) == ["b", "d", "e"]


def test_include_and_exclude():
    indf = pd.DataFrame(columns=["a", "b", "c", "d", "e", "f"]).astype(
        {
            "a": pd.CategoricalDtype([1, 2, 3]),
            "b": "int32",
            "c": pd.CategoricalDtype([1, 2, 3, 4, 5]),
            "d": "float32",
            "e": "bool",
            "f": pd.CategoricalDtype([0, 1]),
        }
    )

    # All categoricals, excluding c
    transformer = UnitTransformer(
        config=dict(input=dict(include=dict(categoricals=True), exclude=["c"]))
    )
    outdf = transformer.transform(indf)
    assert set(outdf.columns) == {"a", "f"}

    # Categoricals with max cardinality of 4, and all numericals,
    # excluding e
    transformer = UnitTransformer(
        config=dict(
            input=dict(
                include=dict(categoricals=dict(max_cardinality=4), numericals=True),
                exclude=["e"],
            )
        )
    )
    outdf = transformer.transform(indf)
    assert set(outdf.columns) == {"a", "b", "d", "f"}

    # Numericals and a, excluding d
    transformer = UnitTransformer(
        config=dict(
            input=dict(include=dict(numericals=True, columns=["a"]), exclude=["d"])
        )
    )
    outdf = transformer.transform(indf)
    assert set(outdf.columns) == {"a", "b", "e"}

    # Non-binary categoricals
    transformer = UnitTransformer(
        config=dict(input=dict(include=dict(categoricals=dict(min_cardinality=3))))
    )
    outdf = transformer.transform(indf)
    assert set(outdf.columns) == {"a", "c"}
