import pandas as pd

from ell.predictions import utils


def test_parquet_dataset_loader(tmpdir_factory):
    tmpdir = tmpdir_factory.mktemp("test_batched_loading")

    part0_df = pd.DataFrame([(1, 2, 3)], columns=["a", "b", "c"], dtype="int64")
    part1_df = pd.DataFrame([(4, 5, 6)], columns=["a", "b", "c"], dtype="int64")

    part0_df.to_parquet(str(tmpdir.join("part0.parquet")))
    part1_df.to_parquet(str(tmpdir.join("part1.parquet")))

    part0_df = part0_df.astype("int32")
    part1_df = part1_df.astype("int32")

    loader = utils.ParquetDatasetLoader(
        str(tmpdir),
        columns=["a", "b", "c"],
        batch_size=12,
    )
    with loader:
        batches = loader.get_batches()
        assert len(batches) == 2
        pd.testing.assert_frame_equal(batches[0], part0_df)
        pd.testing.assert_frame_equal(batches[1], part1_df)

        df = loader.load()
        expected_df = pd.concat([part0_df, part1_df], ignore_index=True)
        pd.testing.assert_frame_equal(df, expected_df)

    loader = utils.ParquetDatasetLoader(
        str(tmpdir),
        columns=["a", "b"],
        index_columns=["a"],
        batch_size=12,
    )
    with loader:
        batches = loader.get_batches()
        assert len(batches) == 2
        expected_df_part0 = part0_df.drop(columns="c").set_index("a")
        pd.testing.assert_frame_equal(batches[0], expected_df_part0)
        expected_df_part1 = part1_df.drop(columns="c").set_index("a")
        pd.testing.assert_frame_equal(batches[1], expected_df_part1)

        df = loader.load()
        expected_df = pd.concat([expected_df_part0, expected_df_part1])
        pd.testing.assert_frame_equal(df, expected_df)
