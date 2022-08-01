resource aws_cloudwatch_log_group etl_logs {
  name = "epp/describers"

  tags = {
    component = "describers"
  }
}


resource aws_cloudwatch_log_group container_logs {
  name = "epp/describers/containers"

  tags = {
    component = "describers"
  }
}

resource aws_cloudwatch_log_group container_runner_logs {
  name = "/aws/sfn/describers-container-runner"

  tags = {
    component = "describers"
  }
}
