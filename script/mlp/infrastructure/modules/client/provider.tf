provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/software-engineer"
    session_name = "software-engineer@${var.workspace_name}-epp"
  }
}


provider aws {
  alias  = "epp"
  region = "ap-southeast-2"

  assume_role {
    # Event Prediction Platform workspace account
    role_arn     = "arn:aws:iam::864206818498:role/software-engineer"
    session_name = "software-engineer@epp"
  }
}
