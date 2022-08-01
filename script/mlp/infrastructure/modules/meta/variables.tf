variable "workspace_account_ids" {
  type = list(string)
}

variable "region" {
  default = "ap-southeast-2"
}

locals {
  account_id      = "864206818498"
  artefact_bucket = "artefact.epp.els.com"
  docs_bucket     = "docs.els.com"
}
