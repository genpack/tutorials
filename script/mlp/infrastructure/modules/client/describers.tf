/* These are the "legacy" describers.
 * The infrastructure for describers in the pipeline is located in the
 * "describers" *module*.
 */

resource aws_ecs_task_definition service-describers {
  family             = "describers"
  task_role_arn      = data.aws_iam_role.describers.arn
  execution_role_arn = data.aws_iam_role.describers.arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"
  memory                   = "30720"

  container_definitions = templatefile(
    "${path.module}/service-describers.tpl",
    {
      REPOSITORY_URI = data.aws_ecr_repository.ecr_repository.repository_url
      IMAGE_VERSION  = var.workspace_name == "default_workspace" ? "dev" : "v5.14.3"
    }
  )

  tags = {
    component = "describers"
  }
}

resource aws_ecs_service service-describers {
  name            = "service-describers"
  task_definition = aws_ecs_task_definition.service-describers.arn
  cluster         = data.aws_ecs_cluster.epp.id

  launch_type         = "FARGATE"
  desired_count       = 0
  scheduling_strategy = "REPLICA"
  propagate_tags      = "TASK_DEFINITION"

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  network_configuration {
    subnets = data.aws_subnet_ids.epp-prod-private-subnets.ids
    security_groups = [
    data.aws_security_group.epp-prod-default-sg.id]
  }
}

resource "aws_appautoscaling_target" ecs_target {
  max_capacity       = 100
  min_capacity       = 0
  resource_id        = "service/${data.aws_ecs_cluster.epp.cluster_name}/${aws_ecs_service.service-describers.name}"
  role_arn           = "arn:aws:iam::${var.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource aws_appautoscaling_policy ecs_policy {
  name               = "describers"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 1
      scaling_adjustment          = 0
    }
    step_adjustment {
      metric_interval_lower_bound = 1
      metric_interval_upper_bound = 10
      scaling_adjustment          = 1
    }
    step_adjustment {
      metric_interval_lower_bound = 10
      metric_interval_upper_bound = 100
      scaling_adjustment          = 10
    }
    step_adjustment {
      metric_interval_lower_bound = 100
      metric_interval_upper_bound = 1000
      scaling_adjustment          = 100
    }
    step_adjustment {
      metric_interval_lower_bound = 1000
      scaling_adjustment          = 200
    }
  }
}

resource aws_cloudwatch_metric_alarm describers-alarm {
  alarm_name = "describers"
  alarm_actions = [
  aws_appautoscaling_policy.ecs_policy.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  cutpoint           = "0"

  metric_query {
    id          = "e1"
    expression  = "m1+m2"
    label       = "AvailableItemsInQueue"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = "300"
      stat        = "Maximum"

      dimensions = {
        QueueName = aws_sqs_queue.describer-job-queue.name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      namespace   = "AWS/SQS"
      period      = "300"
      stat        = "Maximum"

      dimensions = {
        QueueName = aws_sqs_queue.describer-job-queue.name
      }
    }
  }

  tags = {
    component = "engine"
  }
}

resource aws_sqs_queue describer-job-queue {
  name = "describer-jobs"
  # 3 hours
  message_retention_seconds = 10800
  receive_wait_time_seconds = 0

  tags = {
    component = "describers"
  }
}

resource aws_dynamodb_table describers-results {
  hash_key     = "id"
  range_key    = "path"
  name         = "describers"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "path"
    type = "S"
  }

  tags = {
    component = "describers"
  }
}

resource aws_glue_catalog_database describers {
  name = "describers"
}