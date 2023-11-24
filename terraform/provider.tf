provider "aws" {
  region = var.region

  # localstack
  profile = "personal"
  # s3_use_path_style = true

  # access_key                  = "test"
  # secret_key                  = "test"
  # skip_credentials_validation = true
  # skip_metadata_api_check     = true
  # skip_requesting_account_id  = true


  # endpoints {
  #   dynamodb = "http://localhost:4566"
  #   lambda   = "http://localhost:4566"
  #   kinesis  = "http://localhost:4566"
  #   firehose = "http://localhost:4566"
  #   iam =  "http://localhost:4566"
  #   s3 = "http://localhost:4566"
  #   kms = "http://localhost:4566"
  #   cloudwatchlogs = "http://localhost:4566"
  # }
}
