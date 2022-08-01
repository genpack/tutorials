provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${local.account_id}:role/software-engineer"
    session_name = "software-engineer@epp"
  }
}
