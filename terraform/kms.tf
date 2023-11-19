resource "aws_kms_key" "dynamodb_key" {
  description             = "This key is used to encrypt dynamodb table"
  deletion_window_in_days = 7

  enable_key_rotation = true

  tags = var.tags
}
