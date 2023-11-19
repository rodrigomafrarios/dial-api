resource "aws_dynamodb_table" "task_table" {
  name         = "${var.name}-tasks"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "PK"
  range_key = "SK"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  deletion_protection_enabled = var.env == "dev" ? true : false

  server_side_encryption {
    kms_key_arn = aws_kms_key.dynamodb_key.arn
    enabled     = true
  }

  tags = var.tags
}
