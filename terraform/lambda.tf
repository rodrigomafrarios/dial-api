data "archive_file" "app_code" {
  type = "zip"
  source_file = "../../api/app.py"
  output_path = "./app_handler.zip"
}

resource "aws_lambda_function" "main_lambda" {
  function_name    = "${var.env}-main-function"
  role             = aws_iam_role.main_lambda_role.arn
  timeout          = 10
  filename         = data.archive_file.app_code.output_path
  source_code_hash = data.archive_file.app_code.output_base64sha256
  runtime          = "python3.10"
  architectures    = ["arm64"]
  handler          = "app.lambda_handler"
  memory_size      = 256
  layers = [
    aws_lambda_layer_version.common_helpers_layer.arn,
    "arn:aws:lambda:${var.region}:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:37",
    "arn:aws:lambda:${var.region}:336392948345:layer:AWSSDKPandas-Python310-Arm64:3",
  ]

  environment {
    variables = {
      LOG_LEVEL               = "INFO"
      POWERTOOLS_SERVICE_NAME = "${var.env}-${var.name}"
      TABLE_NAME: aws_dynamodb_table.task_table.name,
      POWERTOOLS_METRICS_NAMESPACE: var.name,
      POWERTOOLS_SERVICE_NAME: var.name,
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = var.tags
}
