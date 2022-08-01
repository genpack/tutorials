data "aws_iam_role" "describers" {
  name = "describers"
}

data "aws_iam_role" "predictions" {
  name = "epp"
}

data "aws_vpc" "epp-ecs-vpc" {
  filter {
    name   = "tag:Name"
    values = ["epp-ecs-cluster"]
  }
}

data "aws_vpc" "epp-prod-vpc" {
  filter {
    name   = "tag:Name"
    values = ["epp-prod-vpc"]
  }
}

data aws_subnet_ids epp-prod-private-subnets {
  vpc_id = data.aws_vpc.epp-prod-vpc.id

  filter {
    name   = "tag:SubnetType"
    values = ["private"]
  }
}

data aws_security_group epp-prod-default-sg {
  vpc_id = data.aws_vpc.epp-prod-vpc.id
  name = "default"
}

data "aws_ecs_cluster" epp {
  cluster_name = "epp"
}

data "aws_iam_role" "describers-autoscaling-role" {
  name = "describers-autoscaling-defaultrole"
}

data aws_ecr_repository ecr_repository {
  name = "prediction"

  provider = aws.epp
}
