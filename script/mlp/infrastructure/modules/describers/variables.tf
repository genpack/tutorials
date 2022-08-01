variable "region" {
  default = "ap-southeast-2"
}

variable "workspace_name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "ecr_repository" {
  type = object({
    arn            = string
    repository_url = string
  })
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "container_timeout_minutes" {
  default     = 60
  type        = number
  description = "Timeout before an describer container gets terminated in minutes"
}

locals {
  branch             = var.workspace_name == "default_workspace" ? "develop" : "master"
  artefact_bucket    = "artefact.epp.els.com"
  code_location      = "${local.artefact_bucket}/describers/refs/heads/${local.branch}"
  eventlogs_bucket   = "aws-logs-${var.account_id}-${var.region}"
  eventlogs_location = "${local.eventlogs_bucket}/glue-eventlogs/describers"
  bucket             = "describer.prod.epp.${var.workspace_name}.els.com"

  extra_spark_conf = [
    "spark.cleaner.referenceTracking.cleanCheckpoints=true",
    "spark.checkpoint.compress=true",
    "spark.sql.broadcastTimeout=600",

    # This is required to avoid potential ambiguity between spark versions when reading/writing
    # dates before 1582-10-15 and timestamps before 1900-01-01T00:00:00Z. See the following issue
    # for details https://issues.apache.org/jira/browse/SPARK-31404
    "spark.sql.legacy.parquet.int96RebaseModeInWrite=CORRECTED",
    "spark.sql.legacy.parquet.int96RebaseModeInRead=CORRECTED",
    "spark.sql.legacy.parquet.datetimeRebaseModeInWrite=CORRECTED",
    "spark.sql.legacy.parquet.datetimeRebaseModeInRead=CORRECTED",
  ]
}
