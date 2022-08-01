terraform {
  required_version = "~>1.0.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~>2.1"
    }
    external = {
      source = "hashicorp/external"
    }
  }

  backend "s3" {
    bucket         = "terraform.els.com"
    key            = "epp/prediction/prod.tfstate"
    dynamodb_table = "terraform-epp-state-lock-dynamo"
    region         = "ap-southeast-2"
    role_arn       = "arn:aws:iam::797795491045:role/software-engineer"
    session_name   = "software-engineer@terraform"
  }
}


data "external" "load_workspaces" {
  program = ["python", "-m", "json.tool", "${path.module}/../workspaces.json"]
}

locals {
  workspaces = data.external.load_workspaces.result
}

module "ws08" {
  source = "../modules/workspace"

  workspace_name = "ws08"
  account_id  = local.workspaces["ws08"]

  tier = "L"
}

module "ws07" {
  source = "../modules/workspace"

  workspace_name = "ws07"
  account_id  = local.workspaces["ws07"]

  tier = "S"
}

module "auswide" {
  source = "../modules/workspace"

  workspace_name = "auswide"
  account_id  = local.workspaces["auswide"]

  tier = "S"
}

module "ws11" {
  source = "../modules/workspace"

  workspace_name = "ws11"
  account_id  = local.workspaces["ws11"]

  tier = "S"
}

module "ws12" {
  source = "../modules/workspace"

  workspace_name = "ws12"
  account_id  = local.workspaces["ws12"]

  tier = "S"
}

module "ws13" {
  source = "../modules/workspace"

  workspace_name = "ws13"
  account_id  = local.workspaces["ws13"]

  tier = "M"
}

module "ws04" {
  source = "../modules/workspace"

  workspace_name = "ws04"
  account_id  = local.workspaces["ws04"]

  tier = "S"
}

module "ws05" {
  source = "../modules/workspace"

  workspace_name = "ws05"
  account_id  = local.workspaces["ws05"]

  tier = "L"
}

module "ws14" {
  source = "../modules/workspace"

  workspace_name = "ws14"
  account_id  = local.workspaces["ws14"]

  tier = "S"
}

module "ws02" {
  source = "../modules/workspace"

  workspace_name = "ws02"
  account_id  = local.workspaces["ws02"]

  tier                       = "L"
  predictions_disk_space_gib = 40 # All old revisions need to be deleted after this change is deployed for it to be applied
}

module "ws01" {
  source = "../modules/workspace"

  workspace_name = "ws01"
  account_id  = local.workspaces["ws01"]

  tier = "M"
}

module "ws06" {
  source = "../modules/workspace"

  workspace_name = "ws06"
  account_id  = local.workspaces["ws06"]

  tier = "L"
}

module "ws09" {
  source = "../modules/workspace"

  workspace_name = "ws09"
  account_id  = local.workspaces["ws09"]

  tier                                = "L"
  predictions_disk_space_gib          = 80 # All old revisions need to be deleted after this change is deployed for it to be applied
  describer_container_timeout_minutes = 90
}

module "ws03" {
  source = "../modules/workspace"

  workspace_name = "ws03"
  account_id  = local.workspaces["ws03"]

  tier = "L"
}
