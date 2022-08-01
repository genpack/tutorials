resource aws_ecs_cluster cluster {
  name = "describers"

  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    component = "describers"
  }
}


resource aws_ecs_task_definition container {
  family             = "describers"
  task_role_arn      = data.aws_iam_role.container.arn
  execution_role_arn = data.aws_iam_role.container.arn
  network_mode       = "awsvpc"
  cpu                = 4096
  memory             = 30720

  container_definitions = templatefile(
    "${path.module}/image_definitions.json",
    {
      REPOSITORY_URI : var.ecr_repository.repository_url,
      IMAGE_VERSION : var.workspace_name == "default_workspace" ? "dev" : "latest",
    }
  )

  requires_compatibilities = ["FARGATE"]

  tags = {
    component = "describers"
  }
}
