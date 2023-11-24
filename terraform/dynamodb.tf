resource "aws_dynamodb_table" "task_table" {
  name         = "${var.name}-tasks"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "phone_number"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "phone_number"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "id"
    projection_type = "ALL"
  }

  deletion_protection_enabled = var.env == "dev" ? true : false

  server_side_encryption {
    kms_key_arn = aws_kms_key.dynamodb_key.arn
    enabled     = true
  }

  tags = var.tags
}
