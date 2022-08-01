variable workspace_name {
  type = string
}

variable account_id {
  type = string
}

variable region {
  default = "ap-southeast-2"
}

variable tier {
  type        = string
  description = "Can be either S, M or L and will influence the size of provisioned containers"
}

variable predictions_disk_space_gib {
  default     = 20
  type        = number
  description = "Size of the disk for each predictions container, in GiB"
}

variable describer_container_timeout_minutes {
  default = 60
  type = number
  description = "Timeout before an describer container gets terminated in minutes"
}

locals {
  prediction_timeout = 90
}
