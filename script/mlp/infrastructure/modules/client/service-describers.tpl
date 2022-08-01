[
  {
    "name": "describers",
    "image": "${REPOSITORY_URI}:${IMAGE_VERSION}",
    "entryPoint": ["pipenv", "run", "python", "/main_describers_container.py"],
    "memoryReservation": 30720,
    "cpu": 4096,
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
        "awslogs-stream-prefix": "describers"
      }
    }
  }
]