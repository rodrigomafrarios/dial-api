resource "aws_s3_bucket" "common_layers_bucket" {
  bucket = "${var.env}-${var.name}-lambda-common-layers-bucket"
  force_destroy = var.env == "dev" ? true : false

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "common_layers_bucket_versioning" {
  bucket = aws_s3_bucket.common_layers_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "common_helpers_layer_file" {
  bucket                 = aws_s3_bucket.common_layers_bucket.bucket
  key                    = "${var.env}-common-helpers-layer.zip"
  source                 = "./common_helpers_layer.zip"
  content_type           = "application/zip"
  etag                   = data.archive_file.common_helpers_layer_code.output_md5
  server_side_encryption = "AES256"

  depends_on = [
    aws_s3_bucket.common_layers_bucket
  ]
}

resource "aws_s3_bucket" "tf_backend" {
  bucket = "${var.env}-${var.name}-terraform-backend"
  force_destroy = var.env == "dev" ? true : false

  tags = var.tags
}

resource "aws_s3_bucket" "swagger_bucket" {
  bucket = "${var.env}-${var.name}-swagger-bucket"
  force_destroy = var.env == "dev" ? true : false
  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "swagger_bucket_website" {
  bucket = aws_s3_bucket.swagger_bucket.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "tf_backend_bucket_versionning" {
  bucket = aws_s3_bucket.tf_backend.id
  
    versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "swagger_bucket_versioning" {
  bucket = aws_s3_bucket.swagger_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "swagger_website" {
  bucket = aws_s3_bucket.swagger_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "swagger_website" {
  bucket = aws_s3_bucket.swagger_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "swagger_website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.swagger_website,
    aws_s3_bucket_public_access_block.swagger_website,
  ]

  bucket = aws_s3_bucket.swagger_bucket.id
  acl    = "public-read"
}

locals {
  content_types = {
    css  = "text/css"
    html = "text/html"
    js   = "application/javascript"
  }
}

resource "aws_s3_object" "object" {

  for_each = toset([
    for file in fileset("${path.module}/swagger", "**/*") : file
    if !endswith(file, ".yaml")
  ])


  bucket = aws_s3_bucket.swagger_bucket.bucket
  key    = each.value
  source = "${path.module}/swagger/${each.value}"
  etag   = filemd5("${path.module}/swagger/${each.value}")

  content_type  = lookup(local.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")
  content_encoding = "utf-8"

  depends_on = [ aws_s3_bucket.swagger_bucket ]
}

resource "aws_s3_object" "api_object" {
  key    = "api.yaml"
  content = templatefile("${path.module}/swagger/api.yaml", {api_url = "https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.region}.amazonaws.com/${var.env}"})
  bucket = aws_s3_bucket.swagger_bucket.bucket
  depends_on = [ aws_s3_bucket.swagger_bucket, aws_api_gateway_rest_api.rest_api ]
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.swagger_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.swagger_bucket.arn}/*"
    }
  ]
}
POLICY
}
