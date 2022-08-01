"""Utilities for loading datasets, especially large ones."""

__all__ = [
    "ParquetDatasetBatches",
    "ParquetDatasetLoader",
    "downcast_arrow",
    "downcast_pandas",
]

import logging
import random
import shutil
import tempfile
from typing import (
    ContextManager,
    Dict,
    Iterator,
    List,
    Optional,
    Sequence,
    Tuple,
    Union,
)
from urllib.parse import urlsplit

import numpy as np
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from ell.env.env_abc import AbstractEnv

from ell.predictions import compat

LOGGER = logging.getLogger(__name__)

GB = 1 << 30
BYTE = 8

_DatasetBatchType = Dict[int, Sequence[int]]

_ARROW_DOWNCAST_TYPES = {
    pa.int64(): pa.int32(),
    pa.float64(): pa.float32(),
}
_PANDAS_DOWNCAST_TYPES = {
    "int64": "int32",
    "float64": "float32",
}


def downcast_arrow(table: pa.Table) -> pa.Table:
    """Downcast 64-bit numerical data-types in table to 32-bit."""
    for idx, col in enumerate(table.itercolumns()):
        try:
            new_type = _ARROW_DOWNCAST_TYPES[col.type]
        except KeyError:
            continue
        else:
            col = col.cast(new_type)
            field = table.field(idx).with_type(new_type)
            table = table.set_column(idx, field, col)

    return table


def downcast_pandas(df: pd.DataFrame) -> pd.DataFrame:
    """Downcast 64-bit numerical data-types in DataFrame to 32-bit."""
    to_cast = {}
    for col, dtype in df.dtypes.iteritems():
        try:
            new_type = _PANDAS_DOWNCAST_TYPES[dtype.name]
        except KeyError:
            continue
        else:
            to_cast[col] = new_type

    return df.astype(to_cast)


class ParquetDatasetBatches(Sequence[pd.DataFrame]):
    r"""A sequence-like representation of a batched, on-disk Parquet
    dataset.

    This class behaves like a simple :class:`~collections.abc.Sequence`
    of :class:`~pandas.DataFrame`\ s, however each batch is only loaded
    from Parquet into memory when required.

    This class should not be instantiated directly, but rather via
    :meth:`ParquetDatasetLoader.iter_batches` or
    :meth:`ParquetDatasetLoader.random_iter_batches`.
    """

    def __init__(
        self,
        dataset: pq.ParquetDataset,
        batches: List[_DatasetBatchType],
        columns: Optional[Sequence[str]],
        index_columns: Optional[Sequence[str]],
        encodings: Optional[Dict[str, Dict[Union[int, str], str]]],
        downcast_numericals: bool,
    ) -> None:
        """Constructor for ParquetDatasetBatches.

        This object should not be constructed directly, but rather via a
        :class:`ParquetDatasetLoader` object.
        """
        self._dataset = dataset
        self._batches = batches
        self._columns = columns
        self._index_columns = index_columns
        self._encodings = encodings
        self._downcast_numericals = downcast_numericals

    def __getitem__(self, index: Union[int, slice]) -> pd.DataFrame:
        if isinstance(index, int):
            try:
                batch = self._batches[index]
            except IndexError:
                raise IndexError(f"{type(self).__name__} index out of range") from None
            else:
                return self._load_batch(batch)
        elif isinstance(index, slice):
            batches = self._batches[index]
            return self._load_batches(batches)
        else:
            raise TypeError(
                f"{type(self).__name__} indices must be integers or slices, not "
                f"{type(index).__name__}"
            )

    def __len__(self) -> int:
        return len(self._batches)

    def __contains__(self, other_df: pd.DataFrame) -> bool:
        for my_df in self:
            if my_df.equals(other_df):
                return True
        return False

    def __iter__(self) -> Iterator[pd.DataFrame]:
        return map(self._load_batch, self._batches)

    def __reversed__(self) -> Iterator[pd.DataFrame]:
        return map(self._load_batch, reversed(self._batches))

    @property
    def columns(self) -> Optional[List[str]]:
        if self._columns is not None:
            return list(self._columns)

    def index(
        self, value: pd.DataFrame, start: int = 0, stop: Optional[int] = None
    ) -> int:
        """Return first index of value.

        Raises :exception:`ValueError` if the value is not present.
        """
        if start is not None and start < 0:
            start = max(len(self) + start, 0)
        if stop is not None and stop < 0:
            stop += len(self)

        i = start
        while stop is None or i < stop:
            try:
                my_df = self[i]
                if my_df.equals(value):
                    return i
            except IndexError:
                break
            i += 1
        raise ValueError

    def count(self, value: pd.DataFrame) -> int:
        """Return number of occurrences of value."""
        return sum(1 for my_df in self if my_df.equals(value))

    def _load_batch(self, batch: _DatasetBatchType) -> pd.DataFrame:
        return self._load_batches([batch])

    def _load_batches(self, batches: Sequence[_DatasetBatchType]) -> pd.DataFrame:
        if not batches:
            return pd.DataFrame(columns=self._columns).set_index(self._index_columns)

        tables = []
        for batch in batches:
            for piece_idx, rg_indices in batch.items():
                pf = self._dataset.pieces[piece_idx].open()
                if len(rg_indices) == pf.num_row_groups:
                    table = pf.read(
                        columns=self._columns,
                        use_pandas_metadata=True,
                    )
                else:
                    table = pf.read_row_groups(
                        row_groups=rg_indices,
                        columns=self._columns,
                        use_pandas_metadata=True,
                    )
                if self._downcast_numericals:
                    table = downcast_arrow(table)
                tables.append(table)

        table: pa.Table = pa.lib.concat_tables(tables)

        table = table.replace_schema_metadata()

        return _arrow_to_pandas(
            table, index_columns=self._index_columns, encodings=self._encodings
        )


class ParquetDatasetLoader(ContextManager["ParquetDatasetLoader"]):
    """Class for loading a Parquet dataset as Pandas DataFrame(s).

    It includes features such as:

    * Downloading the dataset from S3 to local disk
    * Batch loading, with a max batch size (in bytes)
    * Random access to batches in the dataset
    * Setting the index of the DataFrame from columns in the dataset
    * Downcasting 64-bit numerical types to 32-bit upon loading

    Examples:

        >>> from ell.predictions.classification import XGBClassifier
        >>> seed = 42
        >>> model = XGBClassifier(config={})
        >>> with ParquetDatasetLoader(
        ...     "s3://bucket/prefix",
        ...     columns=["feature_a", "feature_b", "label"],
        ...     index_columns=["caseID", "eventTime"],
        ... ) as loader:  # The Parquet files are downloaded here
        ...     # Fit model in batches
        ...     shuffled_batches = loader.get_shuffled_batches()
        ...     model.fit(shuffled_batches)
        ...
        ...     batches = loader.get_batches()
        ...     # Predict on the last batch
        ...     df = batches[-1]
        ...     proba_df, cat_df = model.predict(df)
        ... # The Parquet files are implicitly cleaned up here

    """

    def __init__(
        self,
        location: str,
        *,
        columns: Optional[Sequence[str]] = None,
        index_columns: Optional[Sequence[str]] = None,
        encodings: Union[Dict[str, Dict[Union[int, str], str]]] = None,
        batch_size: Optional[int] = None,
        downcast_numericals: bool = True,
        env: AbstractEnv = compat.env,
    ) -> None:
        """Construct the ParquetDatasetLoader.

        Args:
            location: Place where the Parquet files should be loaded
                from. This can be any URI which can be passed to
                :attr:`ell.predictions.compat.env`.
            columns: Columns to load from the Parquet files. If `None`,
                all columns will be loaded.
            index_columns: Columns to set as the DataFrame's index upon
                load.
            encodings: Categorical encodings dictionary, in the
                structure dict{column name -> dict{encoded value ->
                original value}}. The encoded values are expected to be
                all integers (string keys will be coerced to ints).
            batch_size: Maximum size (in bytes) of any loaded batch. If
                `None`, batch-loading will be disabled. Default to 2
                GiB.
            downcast_numericals: If `True`, 64-bit numerical data-types
                will be downcasted to 32-bit. Defaults to `True`.
            env: Environment object to use if you've configured it for
                a certain AWS profile, for example.

        """
        self._location = location
        if urlsplit(self._location).scheme == "s3":
            self._is_local = False
            self._download_location = None
        else:
            self._is_local = True
            self._download_location = location

        self._dataset: Optional[pq.ParquetDataset] = None

        self._columns = None if columns is None else sorted(columns)
        if index_columns is not None and columns is not None:
            colset = frozenset(self._columns)
            self._columns.extend(col for col in index_columns if col not in colset)
        self._index_columns = index_columns
        self._encodings = encodings
        self._batch_size = batch_size
        self._downcast_numericals = downcast_numericals
        self._batches: Optional[List[_DatasetBatchType]] = None
        self._env = env

    @property
    def location(self) -> str:
        """Source location of the dataset's files."""
        return self._location

    def __enter__(self) -> "ParquetDatasetLoader":
        self.download()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.cleanup()

    def __repr__(self) -> str:
        return f"{type(self).__name__}(location={self._location!r})"

    def download(self) -> None:
        """Download the dataset from S3 (if necessary) and validate its
        schema.
        """
        if not self._is_local and self._download_location is None:
            self._download_location = tempfile.mkdtemp()
            LOGGER.info(
                "Downloading Parquet dataset from %r to %r",
                self._location,
                self._download_location,
            )
            filesystem = self._env.get_fs_for_uri(self._location)

            if not self._location.endswith("/") and filesystem.isfile(self._location):
                # Download single file to temp directory.
                # The trailing slash tells fsspec to put the file inside
                # inside the directory
                filesystem.get(self._location, f"{self._download_location}/")
            else:
                # Download multiple files to temporary directory.
                filesystem.get(self._location, self._download_location, recursive=True)

        LOGGER.info("Validating Parquet dataset schema at %r", self._download_location)
        self._dataset = pq.ParquetDataset(self._download_location)

        if self._columns is not None:
            missing_cols = frozenset(self._columns) - frozenset(
                self._dataset.schema.names
            )
            if missing_cols:
                raise ValueError(f"Missing columns: {', '.join(missing_cols)}")

    def load(self) -> pd.DataFrame:
        """Load the entire dataset into a :class:`pandas.DataFrame`."""
        self._ensure_downloaded()
        LOGGER.info(
            "Loading all rows of Parquet dataset at %r into memory",
            self._download_location,
        )
        table = self._dataset.read(columns=self._columns)
        if self._downcast_numericals:
            table = downcast_arrow(table)

        return _arrow_to_pandas(
            table, index_columns=self._index_columns, encodings=self._encodings
        )

    def get_batches(self) -> ParquetDatasetBatches:
        """Get a "virtual" sequence of the batches in this dataset.

        Returns:
            :class:`ParquetDatasetBatches`: A virtual sequence of
            batches of the dataset.

        """
        self._ensure_batches_discovered()
        return ParquetDatasetBatches(
            self._dataset,
            self._batches,
            self._columns,
            self._index_columns,
            self._encodings,
            self._downcast_numericals,
        )

    def get_shuffled_batches(self, seed: int = 0) -> ParquetDatasetBatches:
        """Same as :meth:`get_batches`, but the batches are randomly
        shuffled.

        Args:
            seed (:class:`int`): Random seed to use to shuffle the
            batches.

        Returns:
            :class:`ParquetDatasetBatches`: A virtual sequence of
            batches of the dataset.

        """
        self._ensure_batches_discovered()

        rng = random.Random(seed)
        batches = self._batches.copy()
        rng.shuffle(batches)

        return ParquetDatasetBatches(
            self._dataset,
            batches,
            self._columns,
            self._index_columns,
            self._encodings,
            self._downcast_numericals,
        )

    def maybe_get_batches(self) -> Union[pd.DataFrame, ParquetDatasetBatches]:
        """Like :meth:`~ParquetDatasetLoader.get_batches`, but if a
        ``batch_size`` is not set on this loader, the whole dataset is
        returned as a :class:`pandas.DataFrame`.
        """
        if self._batch_size is None:
            return self.load()
        return self.get_batches()

    def cleanup(self) -> None:
        """Clean up the downloaded parquet files, if necessary."""
        if self._is_local:
            return
        self._dataset = None
        if self._download_location is None:
            return
        LOGGER.info(
            "Cleaning up downloaded Parquet dataset at %r", self._download_location
        )
        shutil.rmtree(
            self._download_location,
            onerror=lambda f, p, e: LOGGER.warning(
                "Error whilst cleaning up downloaded data file: %r",
                e,
                exc_info=e,
            ),
        )
        self._download_location = None

    def _ensure_downloaded(self) -> None:
        if self._dataset is None:
            self.download()

    def _ensure_batches_discovered(self) -> None:
        if self._batch_size is None:
            raise RuntimeError(
                "Cannot load dataset in batches if batch_size is not set"
            )
        self._ensure_downloaded()
        if self._batches is None:
            self._batches = self._discover_batches_of_dataset()

    def _discover_batches_of_dataset(self) -> List[_DatasetBatchType]:
        r"""Discover which row-groups of the Parquet dataset fit into each
        batch.

        The returned structure here describes the indices of the "pieces"
        belonging to each batch, and the row groups within each piece. In
        detail:

        * Each batch is of the structure ``Sequence[Tuple[int,
        Optional[Sequence[int]]]]``\ .
        * Each tuple in the batch contains a pair ``(piece_index,
        row_indices)``\ , or ``(piece_index, None)``. `None` in this case
        means the entire piece is part of the batch.

        """
        LOGGER.debug("Discovering batches of Parquet dataset")
        schema = self._dataset.schema.to_arrow_schema()
        columns = self._columns or [field.name for field in schema]

        # Map the size of each row group with a list in the form:
        # [(piece index, row group index, uncompressed size), ...]
        # We approximate the uncompressed size by multiplying the number of rows
        # in a row group by the bit width of each column's datatype.
        # TODO Make the metadata retrieval faster: PLATFORM-1691
        rg_sizes: List[Tuple[int, int, int]] = []
        for piece_idx, piece in enumerate(self._dataset.pieces):
            piece_meta = piece.get_metadata()
            for rg_idx in range(piece_meta.num_row_groups):
                rg_meta = piece_meta.row_group(rg_idx)
                uncompressed_size = 0
                for column in columns:
                    dtype = schema.field(column).type
                    if self._downcast_numericals:
                        dtype = _ARROW_DOWNCAST_TYPES.get(dtype, dtype)
                    try:
                        dtype_size = dtype.bit_width / BYTE
                    except ValueError:
                        # String dtypes are not fixed width, we assume 512 bit
                        dtype_size = 512 / BYTE
                    uncompressed_size += dtype_size * rg_meta.num_rows
                rg_sizes.append(
                    (
                        piece_idx,
                        rg_idx,
                        uncompressed_size,
                    )
                )

        # Separate each row group into batches
        batches: List[List[Tuple[int, int]]] = []
        cur_batch: List[Tuple[int, int]] = []
        cur_batch_size = 0
        for piece_idx, rg_idx, rg_size in rg_sizes:
            if not cur_batch or cur_batch_size + rg_size <= self._batch_size:
                # We add this row group to the current batch if:
                # - The current batch has no row groups in it yet
                # - If it fits
                cur_batch.append((piece_idx, rg_idx))
                cur_batch_size += rg_size
            else:
                batches.append(cur_batch)
                cur_batch = [(piece_idx, rg_idx)]
                cur_batch_size = rg_size

        if cur_batch:
            batches.append(cur_batch)

        # "Collate" the batches into dictionaries of the form:
        # {piece_idx: [rg_idx, ...], ...}
        collated_batches: List[_DatasetBatchType] = []
        for batch in batches:
            cur_collated_batch = {}
            for piece_idx, rg_idx in batch:
                piece_rgs = cur_collated_batch.setdefault(piece_idx, [])
                piece_rgs.append(rg_idx)
            collated_batches.append(cur_collated_batch)

        LOGGER.debug("Discovered %s batches", len(collated_batches))
        return collated_batches


def _arrow_to_pandas(
    table: pa.Table,
    *,
    index_columns: Optional[Sequence[str]] = None,
    encodings: Optional[Dict[str, Dict[Union[int, str], str]]] = None,
):
    """Convert an Arrow table to a Pandas DataFrame.

    Args:
        table: The Arrow table to convert.
        index_columns: Columns to set as the index of the Pandas
            DataFrame, if any.
        encodings: Dictionary of categorical encodings, used to cast the
            categorical columns to :class:`pandas.CategoricalDtype`.

    """
    # noinspection PyArgumentList
    df: pd.DataFrame = table.to_pandas(date_as_object=False)
    if index_columns is not None:
        df = df.set_index(index_columns)

    if encodings:
        colset = frozenset(df.columns)
        new_dtypes = {}
        null_encodings = []
        missing_encodings = {}
        for column_name, column_encodings in encodings.items():
            if column_name not in colset:
                continue
            if column_encodings is None:
                categories = sorted(df[column_name].drop_duplicates())
                null_encodings.append(column_name)
            else:
                try:
                    categories = sorted(map(int, column_encodings.keys()))
                except ValueError:
                    # Assuming ValueError means the encoded values are not valid ints
                    # Note: We don't really like the premise of a non-int encodeding
                    # for a categorical, but for some reason they slip in.
                    categories = sorted(map(float, column_encodings.keys()))
                missing = sorted(np.setdiff1d(df[column_name], categories))
                if missing:
                    missing_encodings[column_name] = missing
                    categories.extend(missing)
                    categories.sort()
            new_dtypes[column_name] = pd.CategoricalDtype(categories)

        if null_encodings:
            LOGGER.warning(
                "Some columns had a null categorical encodings mapping",
                extra={"data": null_encodings},
            )
        if missing_encodings:
            LOGGER.warning(
                "Some categories found in the data do not appear in the encodings",
                extra={"data": missing_encodings},
            )

        df = df.astype(new_dtypes)

    return df
