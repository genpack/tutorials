resource aws_cloudwatch_log_group ecs_state_changes {
  name = "/aws/events/ecs-state-changes"

  tags = {
    component = "engine"
  }
}

resource aws_cloudwatch_event_rule ecs_state_changes {
  name = "ecs-state-changes"
  event_pattern = jsonencode(
    {
      source      = ["aws.ecs"]
      detail-type = ["ECS Task State Change"]
    }
  )
}

resource aws_cloudwatch_event_target ecs_state_changes {
  target_id = "logs"
  rule      = aws_cloudwatch_event_rule.ecs_state_changes.name
  arn       = aws_cloudwatch_log_group.ecs_state_changes.arn
}
