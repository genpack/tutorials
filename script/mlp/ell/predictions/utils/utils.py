"""Miscellaneous utilities which don't really belong elsewhere."""

__all__ = [
    "download_parquet_dataset",
    "create_path",
    "get_uri_predictions",
    "migrate_module_name",
    "get_environment",
    "get_predictions_glue_schema",
    "create_glue_table",
    "create_table_name",
    "load_hpo",
    "assert_no_na",
    "get_categorical_cols",
    "get_numerical_cols",
    "get_features",
    "import_and_call",
    "trim_params",
    "create_config_filler",
    "ensure_dense",
    "get_data_path",
    "ensure_uri",
    "resolve_param_references",
]

import collections.abc
import importlib
import logging
import os
import re
import shutil
import subprocess as sp
import sys
import tempfile
from copy import deepcopy
from typing import Any, Callable, Container, Dict, List, TYPE_CHECKING, Union

import pandas as pd
import pyarrow as pa
from ell.env.env_abc import AbstractEnv
from ell.env.uri import URI

from ell.predictions import compat
from ell.predictions.utils import ParquetDatasetBatches

if TYPE_CHECKING:
    pass

LOGGER = logging.getLogger(__name__)

_DATABASE_NAME = "predictions"
_LEGACY_IMPORT_RE = re.compile(r"ell\.(?!predictions\.)(.+)")

PREDICTIONS_GLUE_SCHEMA = {
    "caseID": "string",
    "eventTime": "date",
    "probability": "float",
    "category": "int",  # dtype for this column is determined by ``get_predictions_glue_schema()`` if column is present
    "label": "int",  # dtypefor this column is determined by ``get_predictions_glue_schema()`` if column is present
}

GLUE_DTYPE_MAPPING = {
    pa.bool_(): "boolean",
    pa.int8(): "tinyint",
    pa.int16(): "smallint",
    pa.int32(): "int",
    pa.int64(): "bigint",
    pa.float16(): "float",
    pa.float32(): "float",
    pa.float64(): "double",
    pa.uint8(): "smallint",
    pa.uint16(): "int",
    pa.uint32(): "bigint",
    pa.uint64(): "bigint",
}


def download_parquet_dataset(uri: str) -> str:
    """Download a dataset of Parquet files from S3 to a local temporary
    directory, and return its path.
    """
    tmpdir = tempfile.mkdtemp()
    try:
        sp.check_call(
            [
                "aws",
                "s3",
                "cp",
                "--only-show-errors",
                "--recursive",
                uri,
                tmpdir,
            ]
        )
    except:
        shutil.rmtree(tmpdir)
        raise
    else:
        return tmpdir


def create_path(path):
    """Create the directories above the given path."""
    import errno

    if not os.path.exists(os.path.dirname(path)):
        try:
            os.makedirs(os.path.dirname(path))
        except OSError as exc:  # Guard against race condition
            if exc.errno != errno.EEXIST:
                raise


def get_uri_predictions() -> str:
    """Get path to to prediction folder

    Returns:
        str: A path to the prediction folder

    Raises:
        valueError: If current environment is not supported
        supported environments include "local" and "ecs"
    """
    env = get_environment()
    if env == "ecs":
        return (
            "s3://prediction.prod.epp.{}.els.com/executorrun={}/"
            "modulerun={}/predictions/"
        )
    elif env == "local":
        return "{}/tests/executorrun={}/modulerun={}/predictions/"
    else:
        raise ValueError("unsupported environment.")


def migrate_module_name(name: str) -> str:
    """Support pre-ell.predictions import paths.

    Examples:

        >>> migrate_module_name("ell.Transformations.local.Dummifier")
        "ell.predictions.Transformations.local.Dummifier"
        >>> migrate_module_name(
        ...     "ell.predictions.Transformations.local.Dummifier"
        ... )
        "ell.predictions.Transformations.local.Dummifier"

    """
    return _LEGACY_IMPORT_RE.sub(r"ell.predictions.\1", name)


def get_environment() -> str:
    """
    Determines based on system environment variables whether the code
    is being run in spark, ecs, or local mode.

    Returns:
         str: spark | ecs | local

    """

    if ("config" in os.environ and "meta" in os.environ) or (
        "runid" in os.environ and "partition_id" in os.environ
    ):
        return "ecs"
    elif len(sys.argv) > 1 and "--config" in sys.argv and "--meta" in sys.argv:
        return "spark"
    elif os.getenv("AWS_EXECUTION_ENV") and not os.getenv("CODEBUILD_BUILD_ID"):
        return "ecs"
    else:
        return "local"


def create_table_name(executorrun: str, modulerun: str, suffix: str = "") -> str:
    """A unified way of creating table names based on a runid and an
    optional dataset name.
    """
    table_name = f"_{executorrun.replace('-', '_')}_{modulerun.replace('-', '_')}"
    if suffix:
        table_name += f"_{suffix}"
    return table_name


def get_predictions_glue_schema(cats_df: pd.DataFrame) -> Dict[str, str]:
    """Determines the schema of the category and label columns if present"""
    glue_schema = PREDICTIONS_GLUE_SCHEMA.copy()

    variable_dtype_columns = frozenset({"category", "label"})
    available_columns = cats_df.columns.intersection(variable_dtype_columns)
    # noinspection PyArgumentList
    schema = pa.Schema.from_pandas(cats_df[available_columns], preserve_index=False)

    for field in schema:
        glue_schema[field.name] = GLUE_DTYPE_MAPPING.get(field.type, str(field.type))

    return glue_schema


def create_glue_table(
    executorrun: str,
    modulerun: str,
    s3_path: str,
    schema: Dict[str, str],
    table_name_suffix: str = "",
    env: AbstractEnv = compat.env,
):
    """Register a table in Glue pointing to the dataset.

    MUST only be called on the last and final dataframe written out.

    Args:
        executorrun: Agent run ID.
        modulerun: Model run ID.
        s3_path: Path to the dataset in S3.
        schema: Glue schema in the format {colname: dtype}.
        table_name_suffix: Name of the dataset. The table name will be
            as follows: ``_AGENTRUN_MODELRUN_SUFFIX``.
        env: Environment to use.

    """
    table_name = create_table_name(
        executorrun=executorrun, modulerun=modulerun, suffix=table_name_suffix
    )
    LOGGER.info("Creating Glue table %r", table_name)
    columns = [{"Name": col, "Type": dtype} for col, dtype in schema.items()]

    kwargs = dict(
        DatabaseName=_DATABASE_NAME,
        TableInput=dict(
            Name=table_name,
            StorageDescriptor=dict(
                Columns=columns,
                Location=s3_path,
                InputFormat=(
                    "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
                ),
                OutputFormat=(
                    "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
                ),
                SerdeInfo=dict(
                    SerializationLibrary=(
                        "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
                    ),
                    Parameters={"serialization.format": "1"},
                ),
                StoredAsSubDirectories=False,
            ),
            Parameters={"classification": "parquet"},
            TableType="EXTERNAL_TABLE",
        ),
    )

    response = env.glue.create_table(**kwargs)
    LOGGER.debug("glue.CreateTable response", extra={"data": response})


def load_hpo(model):
    """
    Instantiate Hyper Parameter Optimisation class to run.

    :param model: str, a string describes which HPO algorithm to use.
                    e.g. 'ell.HyperparameterTuning.Bayesian'
    :return: class instance.
    """
    object_name = model.split(".")[-1]
    module_name = model[: -len(object_name) - 1]
    module_name = migrate_module_name(module_name)
    module = importlib.import_module(module_name)
    model = getattr(module, object_name)

    return model


def assert_no_na(X, Y=None):
    """Check there are no NA values in the dataset

    Will assert false if any NaN values are found.

    Args:
        X (pd.DataFrame): The input data to check for NA values
        Y (pd.DataFrame or None): Optional classes to check for NA values

    """
    if Y is not None:
        Y = pd.DataFrame(Y)
        assert not Y.isnull().values.any(), "Prediction model passed na y value"
    assert not X.isnull().values.any(), "Prediction model passed na X value"


def get_categorical_cols(df: pd.DataFrame) -> list:
    """Get the classes for all categorical columns in the DataFrame."""
    return [
        col
        for col, dtype in df.dtypes.iteritems()
        if pd.api.types.is_categorical_dtype(dtype)
    ]


def get_numerical_cols(df: pd.DataFrame) -> list:
    """Get the classes for all numerical columns in the DataFrame."""
    return [
        col
        for col, dtype in df.dtypes.iteritems()
        if pd.api.types.is_numeric_dtype(dtype)
    ]


def get_features(dataset, *, labels: List[str]) -> List[str]:
    """Get the feature names from the dataset."""
    if isinstance(dataset, pd.DataFrame):
        return dataset.columns.drop(labels, errors="ignore").to_list()
    elif isinstance(dataset, ParquetDatasetBatches) and dataset.columns is not None:
        labels = frozenset(labels)
        return [col for col in dataset.columns if col not in labels]
    elif isinstance(dataset, collections.abc.Sequence):
        df = dataset[0]
        if not isinstance(df, pd.DataFrame):
            raise TypeError(
                f"Cannot determine features from dataset type "
                f"Sequence[{df.__class__.__name__}]"
            )
        return df.columns.drop(labels, errors="ignore").to_list()
    else:
        raise TypeError(
            f"Cannot determine features from dataset type "
            f"{dataset.__class__.__name__}"
        )


def import_and_call(import_path: str, *args, **kwargs):
    """Import a function or class, and call or instantiate it."""
    module_name, func_or_class_name = import_path.rsplit(".", 1)
    module = importlib.import_module(module_name)
    func_or_class = getattr(module, func_or_class_name)
    return func_or_class(*args, **kwargs)


def trim_params(
    input_params: Dict[str, Any],
    accepted_params: Container[str],
    *,
    warn_for_ignored: bool = True,
) -> Dict[str, Any]:
    """Trims named parameters down to those accepted by the callee.

    If *warn_for_ignored* is `True`, issues a warning for any params
    which are trimmed.
    """
    trimmed_params = {k: v for k, v in input_params.items() if k in accepted_params}
    if warn_for_ignored:
        ignored_params = [k for k in input_params if k not in accepted_params]
        if ignored_params:
            LOGGER.warning(
                "There are %s unrecognised parameters, and they will be ignored",
                len(ignored_params),
                extra={"data": ignored_params},
            )

    return trimmed_params


def create_config_filler(config: dict) -> Callable[[dict], dict]:
    """Get a function to fill out a model config with default values."""

    def _filler(model_cfg: dict) -> dict:
        """Create a full config from just the "model" section."""
        new_cfg = deepcopy(config)
        new_cfg["model"] = model_cfg.copy()
        if "features" in config["model"] and "features" not in new_cfg["model"]:
            new_cfg["model"]["features"] = config["model"]["features"]
        if "labels" in config["model"] and "labels" not in new_cfg["model"]:
            new_cfg["model"]["labels"] = config["model"]["labels"]
        return new_cfg

    return _filler


def ensure_dense(df: pd.DataFrame) -> pd.DataFrame:
    """Convert all sparse data in the DataFrame to dense data."""
    sparse_cols = [
        col for col, dtype in df.dtypes.iteritems() if isinstance(dtype, pd.SparseDtype)
    ]
    if len(sparse_cols) == df.shape[0]:
        LOGGER.debug("Converting entire sparse DataFrame to dense")
        df = df.sparse.to_dense()
    elif len(sparse_cols) > 0:
        LOGGER.debug(
            "Converting %s sparse columns in DataFrame to dense", len(sparse_cols)
        )
        to_assign = {col: df[col].sparse.to_dense() for col in sparse_cols}
        df = df.assign(**to_assign)
    return df


def get_data_path(dataset_spec: Union[str, dict], base_path: str) -> URI:
    """Get the data directory from the 'dataset' key of a config file."""
    base_path = ensure_uri(base_path, is_folder=True)

    data_path = base_path
    if isinstance(dataset_spec, dict):
        if "sampled" in dataset_spec:
            dataset_spec = dataset_spec["sampled"]
        if isinstance(dataset_spec, dict):
            data_path = data_path.run(dataset_spec["run"])
        elif isinstance(dataset_spec, str):
            data_path = data_path.run(dataset_spec)
        else:
            raise TypeError(dataset_spec)
    elif isinstance(dataset_spec, str):
        data_path = data_path.run(dataset_spec)
    else:
        raise TypeError(type(dataset_spec))

    return data_path


def ensure_uri(string: str, *, is_folder: bool = False) -> URI:
    """Coerce a string into a :class:`ell.env.uri.URI`, if
    necessary.
    """
    if isinstance(string, URI):
        return string
    if is_folder:
        string = string.rstrip("\\/")
        string += "/"
    return URI(string)


def resolve_param_references(config: dict) -> dict:
    """Resolve parameter references in a model config.

    This returns a new config with these references resolved everywhere
    there appears a 'parameters' dictionary.

    A reference looks something like ``parameters["key"]``, and refers
    to the parameters in the top-level ``model.classifier.parameters``
    dictionary. This is to allow HPOs to "indirectly" optimise
    parameters elsewhere in the config (such as transformer parameters).

    This will look in the following places for parameter references:

    - ``classifier.calibrator.parameters``
    - ``transformer.parameters`` and any parameters within any sub-
      transformers, i.e. ``transformer.steps[*].parameters`` and so on.
    - Parameters (and the above) of any child models, i.e. all beneath
      ``classifier.models[*]``

    Examples:
        Input config:

        .. code-block:: yaml

            model:
              classifier:
                type: XGBClassifier
                parameters:
                  te_smoothing: 1.0
                  max_depth: 3
              transformer:
                type: TargetEncoder
                parameters:
                  smoothing: 'parameters["te_smoothing"]'

        Output config:

        .. code-block:: yaml

            model:
              classifier:
                type: XGBClassifier
                parameters:
                  te_smoothing: 1.0
                  max_depth: 3
              transformer:
                type: TargetEncoder
                parameters:
                  smoothing: 1.0

    """
    root_params = config["classifier"].get("parameters", {})
    config = deepcopy(config)
    _update_param_references(config, root_params)
    return config


def _update_param_references(config: dict, root_params: dict) -> None:
    """Replace parameter references of the classifier, calibrator,
    and/or transformer(s) in-place, recursing into any child models if
    necessary."""

    classifier_params = config["classifier"].get("parameters", {})
    if classifier_params != root_params:  # Likely we're in a child model
        _update_params_dict(classifier_params, root_params)

    # Resolve param references in calibrator params
    if "calibrator" in config["classifier"]:
        calibrator_params = config["classifier"]["calibrator"].get("parameters", {})
        _update_params_dict(calibrator_params, root_params)

    # Recurse into any child models of an ensembler
    if "models" in config["classifier"]:
        for model_cfg in config["classifier"]["models"]:
            _update_param_references(model_cfg, root_params)

    # Resolve param references in all transformers
    if "transformer" in config:
        _update_transformer_params(config["transformer"], root_params)


def _update_transformer_params(transformer_cfg: dict, root_params: dict) -> None:
    """Replace parameter references in the transformer's parameters,
    recursing into any child transformer (a.k.a. 'steps') in the
    process.
    """
    transformer_params = transformer_cfg.get("parameters", {})
    _update_params_dict(transformer_params, root_params)

    if "steps" in transformer_cfg:
        # Recurse into any sub-transformers
        for step in transformer_cfg["steps"]:
            _update_transformer_params(step, root_params)


PARAM_REF_PATTERN = re.compile(
    r"""
    (?:params|parameters)
    \[
        (?:
            '([^']+)'  # Parameter name contained in single quotes
            |          # OR
            "([^"]+)"  # Parameter name contained in double quotes
        )
    ]
    """,
    re.VERBOSE,
)


def _update_params_dict(params_to_update: dict, root_params: dict) -> None:
    """Replace parameter references in a single parameter dictionary,
    using the given 'root' parameters.

    For example, if a value in ``params_to_update`` looks like
    ``parameters["key"]``, the value will be replaced with the value at
    ``root_params["key"]``.
    """
    for key, value in params_to_update.items():
        if not isinstance(value, str):
            continue
        match = PARAM_REF_PATTERN.match(value)
        if match:
            if match[1] is not None:
                param_name = match[1]
            else:
                param_name = match[2]
            params_to_update[key] = root_params[param_name]
