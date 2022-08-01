resource aws_dynamodb_table jobs {
  name = "DescriberJobs"

  hash_key  = "runid"
  range_key = "attempt_partition_id"

  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "runid"
    type = "S"
  }

  attribute {
    name = "attempt_partition_id"
    type = "S"
  }

  tags = {
    component = "describers"
  }
}
