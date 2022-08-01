[
  {
    "name": "prediction",
    "image": "${REPOSITORY_URI}:${IMAGE_VERSION}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "epp",
        "awslogs-region": "ap-southeast-2",
        "awslogs-stream-prefix": "prediction"
      }
    }
  }
]