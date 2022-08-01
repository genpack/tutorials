provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/software-engineer"
    session_name = "software-engineer@${var.workspace_name}-epp"
  }
}
