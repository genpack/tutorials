import argparse
import json
import logging
import os
import platform
import sys
import time
from datetime import datetime
from math import ceil
from typing import Iterator, List, NamedTuple, Optional, cast

import boto3
import pkg_resources
from boto3.dynamodb.conditions import Key
from ell.env import GlueEnv, uri
from pyspark import TaskContext

from ell.describers import compat

try:
    import pyspark
    from pyspark.sql import DataFrame, Row, SparkSession, types as T, functions as F
except ImportError:
    pyspark = None
    DataFrame = None
    Row = None
    SparkSession = None
    T = None
    F = None

if isinstance(compat.env, GlueEnv):
    compat.env.setup_logging(
        log_uri=(
            uri.root("describer", compat.WORKSPACE_NAME).run(compat.RUN).file("log.txt")
        ),
        log_group="epp/describers",
        run_id=compat.RUN,
    )
else:
    compat.env.setup_logging()
LOGGER = logging.getLogger("ell.describers")
DATABASE_NAME = "describers"

FAILED_STATES = frozenset({"FAILED", "DIED", "TIMED_OUT"})

MAX_ATTEMPTS = 10
DEFAULT_ROWS_PER_CONTAINER = 100
MAX_CONCURRENT_CONTAINERS = 50


def create_table_name(runid: str, dataset: str) -> str:
    """A unified way of creating table names based on a runid and an optional dataset name"""

    name = "_{}_{}".format(runid.replace("-", "_"), dataset)
    return name


def create_glue_table(runid: str, dataset: str, num_partitions: int):
    """
    Register a table in Glue pointing to the dataset. MUST only be called on the last and final
    dataframe written out.
    :param runid: the executorrun ID
    :param dataset: englishing | explanations | scores
    :param num_partitions: the number of physical partitions
    :return:
    """

    glue = boto3.session.Session(region_name="ap-southeast-2").workspace("glue")
    dataset = dataset.lower()
    columns = []

    if dataset not in ["englishing", "explanations", "scores"]:
        LOGGER.warning("tried to create a Glue table for an unknown dataset, abort.")
        return

    if num_partitions > 100:
        LOGGER.warning("too many partitions, tables won't be created manually.")
        return

    if dataset == "englishing":
        columns = [
            ("caseID", "string"),
            ("eventTime", "date"),
            ("explanation_number", "int"),
            ("conversation", "string"),
            ("reason", "string"),
            ("unformatted_reason", "string"),
        ]
    elif dataset == "explanations":
        columns = [
            ("caseID", "string"),
            ("eventTime", "date"),
            ("explanation_number", "int"),
            ("feature", "string"),
            ("actual", "double"),
            ("lower", "double"),
            ("upper", "double"),
        ]
    elif dataset == "scores":
        columns = [
            ("caseID", "string"),
            ("eventTime", "date"),
            ("coverage", "double"),
            ("fidelity", "double"),
            ("final", "boolean"),
            ("gain", "double"),
            ("npv", "double"),
            ("parsimony", "double"),
            ("power", "double"),
            ("precision", "double"),
        ]

    columns = [{"Name": col, "Type": dtype} for col, dtype in columns]
    table_name = create_table_name(runid=runid, dataset=dataset)
    path = "s3://describer.prod.epp.{}.els.com/run={}/{}/".format(
        OPTS.workspace_name, runid, dataset
    )

    kwargs = dict(
        DatabaseName=DATABASE_NAME,
        TableInput=dict(
            Name=table_name,
            StorageDescriptor=dict(
                Columns=columns,
                Location=path,
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
            PartitionKeys=[{"Name": "attempt", "Type": "int"}],
            Parameters={"classification": "parquet"},
            TableType="EXTERNAL_TABLE",
        ),
    )
    response = glue.create_table(**kwargs)
    LOGGER.debug(
        "glue.CreateTable response: %s", json.dumps(response, indent=2, default=str)
    )

    storage_descriptor = kwargs["TableInput"]["StorageDescriptor"]
    kwargs = dict(
        DatabaseName=DATABASE_NAME,
        TableName=table_name,
        PartitionInputList=[
            dict(
                Values=[f"{p:02}"],
                StorageDescriptor=dict(
                    storage_descriptor,
                    Location=storage_descriptor["Location"] + f"attempt={p:02}/",
                ),
            )
            for p in range(num_partitions)
        ],
    )

    response = glue.batch_create_partition(**kwargs)
    LOGGER.debug(
        "glue.BatchCreatePartition response: %s",
        json.dumps(response, indent=2, default=str),
    )


class OptsType(NamedTuple):
    config: str
    meta: str
    task_definition_arn: str
    workspace_name: str
    workspace_number: str
    subnet_ids: str = ""
    security_group_ids: str = ""


argparser = argparse.ArgumentParser()
argparser.add_argument("--subnet-ids")
argparser.add_argument("--security-group-ids")
argparser.add_argument("--config")
argparser.add_argument("--meta")
argparser.add_argument("--task-definition-arn")
argparser.add_argument("--workspace-name")
argparser.add_argument("--workspace-number")
if compat.ON_GLUE:
    OPTS: OptsType = cast(OptsType, argparser.parse_known_args()[0])
    SUBNETS = json.loads(OPTS.subnet_ids)
    SECURITY_GROUPS = json.loads(OPTS.security_group_ids)
    NETWORK_CONFIGURATION = dict(
        subnets=SUBNETS,
        securityGroups=SECURITY_GROUPS,
    )
else:
    OPTS = OptsType(
        config="tests/run=describer/config.yml",
        meta="tests/run=describer/meta.json",
        task_definition_arn="describers",
        workspace_name="n/a",
        workspace_number="0123",
    )
    NETWORK_CONFIGURATION = None


def main():
    LOGGER.info("Start")
    LOGGER.debug("sys.argv", extra={"data": sys.argv})
    LOGGER.debug("os.environ", extra={"data": dict(os.environ)})
    LOGGER.debug("Platform: %s", platform.platform())
    installed_packages = pkg_resources.WorkingSet()
    LOGGER.debug(
        "Packages",
        extra={
            "data": {
                dist.project_name: dist.version
                for dist in sorted(
                    installed_packages, key=lambda dist: dist.project_name.lower()
                )
            }
        },
    )
    LOGGER.debug("Run ID: %s", compat.RUN)

    compat.env.update_meta(
        "STARTED",
        workspace_name=compat.WORKSPACE_NAME,
        component_name="describers",
        run_id=compat.RUN,
    )
    try:
        start()
    except Exception as exc:
        LOGGER.exception("Fatal error: %r", exc)
        state = "FAILED"
    else:
        state = "SUCCEEDED"

    compat.env.update_meta(
        state=state,
        workspace_name=compat.WORKSPACE_NAME,
        component_name="describers",
        run_id=compat.RUN,
    )


def start():
    if pyspark is None:
        raise RuntimeError("PySpark is not installed!")

    run_path = uri.root("describer", compat.WORKSPACE_NAME).run(compat.RUN)
    config = compat.env.read_jsonish(run_path.file("config.json"))
    LOGGER.debug("Config file loaded", extra={"data": config})

    if not submit_and_get_describers(config):
        raise RuntimeError(
            "Some explanations were still bad after max attempts reached"
        )


def repartition_rows(
    df: DataFrame, config: dict, df_count: Optional[int] = None
) -> DataFrame:
    if df_count is None:
        df_count = df.count()
    rows_per_partition = config["rows"].get("per_partition", DEFAULT_ROWS_PER_CONTAINER)
    num_partitions = ceil(df_count / rows_per_partition)
    # Ensure no more than MAX_CONCURRENT_CONTAINERS can run per attempt
    num_partitions = min(num_partitions, MAX_CONCURRENT_CONTAINERS)
    return df.repartition(num_partitions)


def submit_and_get_describers(config) -> bool:
    """Get the rows to describe, submit the describers, run through all
    attempts, until either there are no bad explanations or max
    attempts are reached.

    Returns True when all rows were successfully described, False if
    some were still bad after max attempts were reached.
    """
    # Get the model config file
    prediction_bucket = uri.root("prediction", compat.WORKSPACE_NAME)
    model_spec = config["model"]
    module_path = prediction_bucket.executor(model_spec["executorrun"]).model(
        model_spec["modulerun"]
    )
    model_config = compat.env.read_jsonish(module_path.file("config.json"))
    LOGGER.debug("Retrieved model config", extra={"data": model_config})

    if model_config["mode"] == "infer":
        # Trained model which the containers need to pull is specified
        # in this model config.
        LOGGER.debug(
            "Referenced model is an infer model - getting its train model config"
        )

        # Download train model config to get features
        train_model_spec = model_config["model"]
        train_config_uri = (
            prediction_bucket.executor(train_model_spec["executorrun"])
            .model(train_model_spec["modulerun"])
            .file("config.json")
        )
        train_model_cfg = compat.env.read_jsonish(train_config_uri)
        prediction_features = train_model_cfg["model"].get("features", [])
    else:
        train_model_spec = model_spec
        prediction_features = model_config["model"].get("features", [])

    # Part of the config has to be the reason map.
    reason_map = config.get("reason_map", {})
    manual_context = config.get("manual_context", {})
    describe_features = list(reason_map.keys()) + list(manual_context.keys())

    rows_to_describe = get_rows_to_describe(
        config,
        model_config,
        describe_features,
        prediction_features,
        module_path,
    )
    num_bad_explanations = None
    min_num_good_explanations = config["rows"].get("min_explanations")

    num_possible_attempts = (
        len(config["args"]) if isinstance(config["args"], list) else 1
    )
    if num_possible_attempts > MAX_ATTEMPTS:
        raise ValueError(
            "A maximum of %s sets of parameters can be specified, received %s",
            MAX_ATTEMPTS,
            num_possible_attempts,
        )
    num_rows_described = 0
    num_attempts = 0

    for attempt_number in range(num_possible_attempts):
        num_attempts += 1

        rows_to_describe = repartition_rows(
            rows_to_describe, config, df_count=num_bad_explanations
        )
        rows_to_describe.localCheckpoint(eager=False)
        write_rows_to_describe(rows_to_describe, attempt_number)
        submit_describers(rows_to_describe, train_model_spec, attempt_number)
        monitor_containers(attempt_number)

        describer_output = get_explanations(attempt_number)
        describer_output.localCheckpoint(eager=False)
        num_rows_described += describer_output.drop_duplicates(
            subset=["caseID", "eventTime"]
        ).count()
        LOGGER.info(
            "%s rows have been described after attempt %s",
            num_rows_described,
            attempt_number + 1,
        )
        rows_to_describe = rows_to_describe.join(
            describer_output, on=["caseID", "eventTime"], how="left_anti"
        ).select(rows_to_describe.columns)
        rows_to_describe.localCheckpoint(eager=False)
        num_bad_explanations = rows_to_describe.count()

        LOGGER.info(
            "There are %s bad explanations left after attempt %s",
            num_bad_explanations,
            attempt_number + 1,
        )

        if num_bad_explanations == 0:
            break

    # create Glue tables independent of success of this job
    create_glue_table(
        runid=compat.RUN, dataset="englishing", num_partitions=num_attempts
    )
    create_glue_table(
        runid=compat.RUN, dataset="explanations", num_partitions=num_attempts
    )
    create_glue_table(runid=compat.RUN, dataset="scores", num_partitions=num_attempts)

    if min_num_good_explanations is not None:
        enough_rows_described = num_rows_described >= min_num_good_explanations
    else:
        enough_rows_described = num_bad_explanations == 0

    if enough_rows_described:
        if min_num_good_explanations is not None:
            LOGGER.info(
                "Succeeding, since enough rows have been described (%s >= %s)",
                num_rows_described,
                min_num_good_explanations,
            )
        else:
            LOGGER.info("Succeeding, since there are no more bad explanations")
    else:
        LOGGER.critical(
            "Maximum (%s) attempts reached and there are still not enough rows "
            "described",
            num_possible_attempts,
        )

    return enough_rows_described


def get_rows_to_describe(
    config: dict,
    model_config: dict,
    describe_features: List[str],
    prediction_features: List[str],
    module_path: uri.URI,
) -> DataFrame:
    # Load in sampler
    model_dataset_info = model_config["dataset"]
    if isinstance(model_dataset_info, dict):
        # You can optionally specify both the runid and the folder to use
        dataset_runid = model_dataset_info["sampled"]["run"]
        dataset_folder = model_dataset_info["sampled"]["folder"]
    else:
        # If only a runid is specified, use the dataset corresponding to the model mode
        dataset_runid = model_dataset_info
        dataset_folder = "infer" if model_config["mode"] == "infer" else "test"

    dataset_uri = (
        uri.root("sampled", compat.WORKSPACE_NAME)
        .run(dataset_runid)
        .folder(dataset_folder)
    )

    LOGGER.info("Getting rows to describe from dataset %r", dataset_uri)
    LOGGER.debug("Model config for determining data", extra={"data": model_config})
    LOGGER.debug("prediction_features", extra={"data": prediction_features})
    LOGGER.debug("describe_features", extra={"data": describe_features})

    spark = compat.env.spark_session
    df_dataset = spark.read.parquet(dataset_uri)
    df_dataset = df_dataset.withColumn(
        "eventTime", F.col("eventTime").cast(T.DateType())
    )

    # If the exclude_describers column is provided, filter out rows where it is true
    if "exclude_describers" in df_dataset.columns:
        LOGGER.info("Filtering caseIDs based on exclude_describers column")
        df_dataset = df_dataset.withColumn(
            "exclude_describers", F.col("exclude_describers").cast(T.BooleanType())
        )
        df_dataset = df_dataset.filter(~F.col("exclude_describers"))
    else:
        LOGGER.info("No exclude_describers column provided")

    # Load predictions dataset
    predictions_uri = module_path.folder("predictions")
    LOGGER.info("Getting prediction list from %r", predictions_uri)

    df_list = spark.read.parquet(predictions_uri)
    df_list = df_list.withColumn("eventTime", F.col("eventTime").cast(T.DateType()))

    joined_df = df_list.join(df_dataset, on=["caseID", "eventTime"], how="inner")
    filtered_joined_df = joined_df.filter(F.col("category") == 1)

    rows_info = config["rows"]
    if rows_info["type"] == "list":
        if not isinstance(rows_info["value"], list):
            raise TypeError("If rows type is 'list', rows value must be a list")
        reduced_df = filtered_joined_df.filter(F.col("caseID").isin(rows_info["value"]))
    else:
        # Calculate the number of rows to describe if a list is not provided
        if rows_info.get("value"):
            num_rows = rows_info["value"]
            LOGGER.info("Using %s rows", num_rows)
        elif rows_info.get("ratio"):
            full_row_count = joined_df.count()
            ratio = rows_info["ratio"]
            num_rows = round(full_row_count * ratio)
            LOGGER.info("Using %s (%s%%) rows", num_rows, ratio)
        else:
            raise ValueError(
                f"At least one of 'value' or 'ratio' needs to be provided for rows. Received {rows_info}"
            )

        # Select the correct number of rows either from the top, or randomly
        if rows_info["type"] == "top":
            filtered_joined_df = filtered_joined_df.sort(
                filtered_joined_df.probability, ascending=False
            )
            reduced_df = filtered_joined_df.limit(num_rows)
        elif rows_info["type"] == "random":
            reduced_df = spark.createDataFrame(
                filtered_joined_df.rdd.takeSample(
                    withReplacement=False,
                    num=num_rows,
                    seed=config.get("random_seed"),
                ),
                schema=filtered_joined_df.schema,
            )
        else:
            raise ValueError(
                f"The rows type must be one of top, list, or random. Received {rows_info['type']}"
            )

    rows_to_describe = reduced_df.select(
        *set(prediction_features + describe_features + ["caseID", "eventTime"])
    )

    return rows_to_describe


def write_rows_to_describe(rows_to_describe: DataFrame, attempt_number: int) -> None:
    output_uri = (
        f"{os.path.dirname(OPTS.config)}/rows_to_describe/attempt={attempt_number:02}"
    )
    LOGGER.info("Writing rows to describe to %r", output_uri)

    rows_to_describe.write.parquet(output_uri, mode="overwrite")


def submit_describers(
    rows_to_describe: DataFrame, train_model: dict, attempt_number: int
):
    LOGGER.info("Submitting describers attempt %s", attempt_number)

    runid = compat.RUN
    account_id = compat.ACCOUNT_ID
    train_model_str = json.dumps(train_model)

    def start_container_runner(partition: Iterator[Row]) -> None:
        partition_id = TaskContext.get().partitionId()
        rows = [
            {"caseID": row.caseID, "eventTime": str(row.eventTime)} for row in partition
        ]
        if not rows:
            return

        jobs_table = boto3.resource("dynamodb", region_name="ap-southeast-2").Table(
            "DescriberJobs"
        )
        exc = None

        attempt_partition_id = (
            f"attempt={attempt_number:02}_partition={partition_id:02}"
        )
        state_machine_arn = (
            f"arn:aws:states:ap-southeast-2:{account_id}:"
            f"stateMachine:describers-container-runner"
        )
        state_machine_name = f"{runid}_{attempt_partition_id}"
        sfn = boto3.workspace("stepfunctions", region_name="ap-southeast-2")
        sfn_input = {
            "partitionId": str(partition_id),
            "runid": runid,
            "attemptNumber": str(attempt_number),
            "trainModel": train_model_str,
            "attemptPartitionId": attempt_partition_id,
            "ecsTaskDefinitionArn": OPTS.task_definition_arn,
        }

        for retry in range(8):
            try:
                response = sfn.start_execution(
                    stateMachineArn=state_machine_arn,
                    name=state_machine_name,
                    input=json.dumps(sfn_input),
                )
            except sfn.exceptions.ClientError as _exc:
                exc = _exc
                if _exc.response["Error"]["Code"] == "ExecutionLimitExceeded":
                    time.sleep(2 ** retry)
                else:
                    raise
            else:
                jobs_table.put_item(
                    Item=dict(
                        runid=runid,
                        attempt_partition_id=attempt_partition_id,
                        partition_id=partition_id,
                        attempt_number=attempt_number,
                        rows=rows,
                        state="RECEIVED",
                        start=f"{datetime.utcnow().isoformat(timespec='milliseconds')}Z",
                        sfn_execution_arn=response["executionArn"],
                    )
                )
                break
        else:
            raise exc

    LOGGER.info("Running %s containers", rows_to_describe.rdd.getNumPartitions())
    rows_to_describe.foreachPartition(start_container_runner)


def monitor_containers(attempt_number: int) -> None:
    jobs_table = boto3.resource("dynamodb", region_name="ap-southeast-2").Table(
        "DescriberJobs"
    )
    completed = {}

    while True:
        time.sleep(30)

        response = jobs_table.query(
            KeyConditionExpression=Key("runid").eq(compat.RUN),
            ProjectionExpression="#p, #s, #t",
            ExpressionAttributeNames={
                "#p": "partition_id",
                "#s": "state",
                "#t": "sfn_execution_arn",
            },
            FilterExpression=Key("attempt_number").eq(attempt_number),
        )
        pending = {}
        for item in response["Items"]:
            partition_id = int(item["partition_id"])
            if partition_id in completed:
                continue
            if item["state"] in ("RECEIVED", "STARTED"):
                pending[partition_id] = item["state"]
            else:
                completed[partition_id] = (item["state"], item["sfn_execution_arn"])
                LOGGER.info(
                    "Container %s (SFN Execution ARN: %s) has finished with state %r",
                    partition_id,
                    item["sfn_execution_arn"],
                    item["state"],
                )

        if pending:
            LOGGER.debug(
                "Pending jobs (attempt %s)", attempt_number, extra={"data": pending}
            )
        else:
            LOGGER.info(
                "No more pending jobs - monitoring finished for attempt %s",
                attempt_number,
            )
            failed_containers = {
                pid: sfn_execution_arn
                for pid, (state, sfn_execution_arn) in completed.items()
                if state in FAILED_STATES
            }
            if failed_containers:
                if len(failed_containers) == len(completed):
                    LOGGER.critical(
                        "All containers failed in attempt %s",
                        attempt_number,
                        extra={"data": failed_containers},
                    )
                else:
                    LOGGER.critical(
                        "These containers failed in attempt %s",
                        attempt_number,
                        extra={"data": failed_containers},
                    )
                raise RuntimeError("Not all containers succeeded")
            else:
                LOGGER.info("All containers succeeded in attempt %s", attempt_number)
                break


def get_explanations(attempt_number: Optional[int] = None) -> DataFrame:
    """Read the `explanations` output from containers and return as a
    Spark DataFrame.
    """
    spark = compat.env.spark_session
    explanations_uri = f"{os.path.dirname(OPTS.config)}/explanations"
    if attempt_number is not None:
        explanations_uri += f"/attempt={attempt_number:02}"
    LOGGER.info("Reading explanations from %r", explanations_uri)

    return spark.read.parquet(explanations_uri)


if __name__ == "__main__":
    main()
