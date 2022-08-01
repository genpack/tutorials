resource aws_sfn_state_machine container_runner {
  name     = "describers-container-runner"
  role_arn = "arn:aws:iam::${var.account_id}:role/describers-container-runner"

  definition = jsonencode(
  {
    Comment : "Run Describer Container until completion, timeout, or failure",
    StartAt : "RunDescriberContainer",
    States : {
      RunDescriberContainer : {
        Type : "Task",
        Resource : "arn:aws:states:::ecs:runTask.sync",
        Parameters : {
          LaunchType : "FARGATE",
          Cluster : "describers",
          "TaskDefinition.$" : "$.ecsTaskDefinitionArn",
          NetworkConfiguration : {
            AwsvpcConfiguration : {
              Subnets : var.subnet_ids,
              SecurityGroups : var.security_group_ids,
              AssignPublicIp : "ENABLED",
            }
          },
          PropagateTags: "TASK_DEFINITION",
          Overrides : {
            ContainerOverrides : [
              {
                Name : "describers"
                Environment : [
                  {
                    Name : "name",
                    Value : var.workspace_name
                  },
                  {
                    Name : "account_number",
                    Value : var.account_id
                  },
                  {
                    Name : "partition_id",
                    "Value.$" : "$.partitionId"
                  },
                  {
                    Name : "runid",
                    "Value.$" : "$.runid"
                  },
                  {
                    Name : "attempt_number",
                    "Value.$" : "$.attemptNumber"
                  },
                  {
                    Name : "train_model",
                    "Value.$" : "$.trainModel"
                  },
                ]
              }
            ]
          }
        },
        TimeoutSeconds : var.container_timeout_minutes * 60,
        Retry : [
          {
            ErrorEquals : [
              "ECS.AmazonECSException",
            ],
            IntervalSeconds : 1,
            MaxAttempts : 8,
            BackoffRate : 2
          }
        ],
        Catch : [
          {
            ErrorEquals : [
              "States.Timeout"
            ],
            Next : "ContainerTimedOut"
            ResultPath: "$.error"
          },
          {
            ErrorEquals : [
              "States.Runtime"
            ],
            Next : "ContainerDied"
            ResultPath: "$.error"
          },
          {
            ErrorEquals : [
              "States.TaskFailed"
            ],
            Next : "ContainerDied"
            ResultPath: "$.error"
          }
        ],
        Next: "ContainerFinished"
        ResultPath: "$.result"
      },
      ContainerFinished : {
        Type: "Succeed"
      },
      ContainerTimedOut: {
        Type: "Task",
        Resource: "arn:aws:states:::dynamodb:updateItem",
        Parameters: {
          Key: {
            "runid.$": "$.runid",
            "attempt_partition_id.$": "$.attemptPartitionId"
          },
          TableName: "DescriberJobs",
          UpdateExpression: "Set #state = :state, #end = :end"
          ExpressionAttributeNames: {
            "#state": "state",
            "#end": "end",
          },
          ExpressionAttributeValues: {
            ":state": "TIMED_OUT",
            ":end.$": "$$.State.EnteredTime"
          }
        },
        Retry : [
          {
            ErrorEquals : [
              "DynamoDB.AmazonDynamoDBException",
            ],
            IntervalSeconds : 5,
            MaxAttempts : 3,
            BackoffRate : 1.0
          }
        ],
        End: true
      },
      ContainerDied: {
        Type: "Task",
        Resource: "arn:aws:states:::dynamodb:updateItem",
        Parameters: {
          Key: {
            "runid.$": "$.runid",
            "attempt_partition_id.$": "$.attemptPartitionId"
          },
          TableName: "DescriberJobs",
          UpdateExpression: "Set #state = :state, #end = :end"
          ExpressionAttributeNames: {
            "#state": "state",
            "#end": "end",
          },
          ExpressionAttributeValues: {
            ":state": "DIED",
            ":end.$": "$$.State.EnteredTime"
          }
        },
        Retry : [
          {
            ErrorEquals : [
              "DynamoDB.AmazonDynamoDBException",
            ],
            IntervalSeconds : 5,
            MaxAttempts : 3,
            BackoffRate : 1.0
          }
        ],
        End: true
      }
    }
  }
  )

  //noinspection HCLUnknownBlockType
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.container_runner_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}