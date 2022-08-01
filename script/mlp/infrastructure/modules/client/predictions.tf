resource aws_ecs_task_definition task-prediction {
  family             = "prediction"
  task_role_arn      = data.aws_iam_role.predictions.arn
  execution_role_arn = data.aws_iam_role.predictions.arn

  container_definitions = templatefile(
    "${path.module}/task-predictions.tpl",
    {
      REPOSITORY_URI = data.aws_ecr_repository.ecr_repository.repository_url
      IMAGE_VERSION  = var.workspace_name == "default_workspace" ? "dev" : "latest"
    }
  )

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.tier == "S" ? "1024" : var.tier == "M" ? "2048" : "4096"
  memory                   = var.tier == "S" ? "8192" : var.tier == "M" ? "15360" : "30720"

  # If the ephemeral storage is equal to the default, the whole
  # ephemeral_stoarge block **must** be omitted. Thanks AWS!
  dynamic ephemeral_storage {
    for_each = (
      var.predictions_disk_space_gib == 20
      ? []
      : [0]
    )
    content {
      size_in_gib = var.predictions_disk_space_gib
    }
  }

  tags = {
    component = "predictions"
  }
}

resource "aws_sqs_queue" "prediction-queue-spark" {
  name                       = "prediction-spark"
  message_retention_seconds  = 600
  visibility_timeout_seconds = local.prediction_timeout

  tags = {
    component = "engine"
  }
}

resource "aws_sqs_queue" "prediction-queue-local" {
  name                      = "prediction-local"
  message_retention_seconds = 86400
  # 1 day
  visibility_timeout_seconds = local.prediction_timeout

  tags = {
    component = "engine"
  }
}

resource "aws_cloudwatch_log_group" "loggroup" {
  name = "epp"

  tags = {
    component = "engine"
  }
}

resource aws_glue_catalog_database predictions {
  name = "predictions"
}