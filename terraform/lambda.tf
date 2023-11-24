data "archive_file" "app_code" {
  type = "zip"
  source_file = "../src/app.py"
  output_path = "./app_handler.zip"
}

data "archive_file" "create_phone_numbers_code" {
  type = "zip"
  source_file = "../src/create_phone_numbers.py"
  output_path = "./create_phone_numbers_handler.zip"
}

resource "aws_lambda_function" "main_lambda" {
  function_name    = "${var.env}-main-function"
  role             = aws_iam_role.main_lambda_role.arn
  timeout          = 30
  filename         = data.archive_file.app_code.output_path
  source_code_hash = data.archive_file.app_code.output_base64sha256
  runtime          = "python3.10"
  architectures    = ["arm64"]
  handler          = "app.lambda_handler"
  memory_size      = 512
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
      EVENT_BUS: aws_cloudwatch_event_bus.event_bus.name,
      POWERTOOLS_METRICS_NAMESPACE: var.name,
      POWERTOOLS_SERVICE_NAME: var.name,
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = var.tags
}

resource "aws_lambda_function" "create_task_lambda" {
  function_name    = "${var.env}-create-task-function"
  role             = aws_iam_role.main_lambda_role.arn
  timeout          = 30
  filename         = data.archive_file.create_phone_numbers_code.output_path
  source_code_hash = data.archive_file.create_phone_numbers_code.output_base64sha256
  runtime          = "python3.10"
  architectures    = ["arm64"]
  handler          = "create_phone_numbers.lambda_handler"
  memory_size      = 512
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
