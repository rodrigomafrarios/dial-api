resource "aws_lambda_permission" "allow_api_gw_main_lambda" {
  statement_id  = "AllowExecutionFromApiGW"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}
