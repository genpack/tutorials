terraform {
  required_version = "~>1.0.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~>1.3"
    }
    external = {
      source  = "hashicorp/external"
      version = "~>1.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "~>2.1"
    }
  }

  backend s3 {
    bucket         = "terraform.els.com"
    key            = "epp/prediction/dev.tfstate"
    dynamodb_table = "terraform-epp-state-lock-dynamo"
    region         = "ap-southeast-2"
    role_arn       = "arn:aws:iam::797795491045:role/software-engineer"
    session_name   = "software-engineer@terraform"
  }
}


data external load_workspaces {
  program = ["python", "-m", "json.tool", "${path.module}/../workspaces.json"]
}

locals {
  workspaces = data.external.load_workspaces.result
}


module "meta" {
  source = "../modules/meta"

  workspace_account_ids = values(local.workspaces)
}

module "default_workspace" {
  source = "../modules/workspace"

  workspace_name     = "default_workspace"
  account_id      = local.workspaces["default_workspace"]

  tier = "L"
}
