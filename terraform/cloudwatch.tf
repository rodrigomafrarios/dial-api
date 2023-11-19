resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api-gateway/${var.env}-${aws_api_gateway_rest_api.rest_api.id}"

  # TODO: how many days of retention?
  retention_in_days = 7

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "main_lambda" {
  name = "/aws/lambda/${aws_lambda_function.main_lambda.function_name}"

  # TODO: how many days of retention?
  retention_in_days = 7

  tags = var.tags
}


resource "aws_cloudwatch_log_group" "api_gw_execution_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.rest_api.id}/${aws_api_gateway_stage.rest_api_stage.stage_name}"
  retention_in_days = 7
}
