module describers {
  source = "../describers"

  region      = var.region
  workspace_name = var.workspace_name
  account_id  = var.account_id

  ecr_repository     = data.aws_ecr_repository.ecr_repository
  vpc_id             = data.aws_vpc.epp-prod-vpc.id
  subnet_ids         = data.aws_subnet_ids.epp-prod-private-subnets.ids
  security_group_ids = [data.aws_security_group.epp-prod-default-sg.id]

  container_timeout_minutes = var.describer_container_timeout_minutes
}
