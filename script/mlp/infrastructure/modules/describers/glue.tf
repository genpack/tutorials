resource "aws_glue_job" "etl" {
  name     = "describers"
  role_arn = data.aws_iam_role.etl.arn

  glue_version      = "3.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    script_location = "s3://${local.code_location}/main.py"
    python_version  = "3"
  }

  non_overridable_arguments = {
    "--enable-metrics"                        = ""
    "--enable-continuous-cloudwatch-log"      = "true"
    "--enable-continuous-log-filter"          = "true"
    "--enable-spark-ui"                       = "true"
    "--enable-s3-parquet-optimized-committer" = "true"
    "--spark-event-logs-path"                 = "s3://${local.eventlogs_location}"
    "--TempDir"                               = "s3://${local.bucket}/_temporary"
    "--region-name"                           = var.region

    "--workspace-name"        = var.workspace_name
    "--workspace-number"      = var.account_id
    "--vpc-id"             = var.vpc_id
    "--subnet-ids"         = jsonencode(var.subnet_ids)
    "--security-group-ids" = jsonencode(var.security_group_ids)

    "--conf" = join(" --conf ", local.extra_spark_conf)
  }

  default_arguments = {
    "--task-definition-arn"            = aws_ecs_task_definition.container.arn
    "--continuous-log-logStreamPrefix" = "describers"
    "--additional-python-modules"      = "ell.predictions[spark]"
  }

  execution_property {
    max_concurrent_runs = 100
  }

  tags = {
    component = "describers"
  }
}
