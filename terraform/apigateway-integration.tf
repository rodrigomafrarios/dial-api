resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  resource_id             = aws_api_gateway_resource.proxy_rest_api_resource.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_BINARY"
  uri                     = aws_lambda_function.main_lambda.invoke_arn
}


resource "aws_api_gateway_method_response" "proxy_method_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_rest_api_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Expose-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Max-Age" = true,
  }
}

resource "aws_api_gateway_integration_response" "proxy_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_rest_api_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = aws_api_gateway_method_response.proxy_method_response.status_code

  depends_on = [ aws_api_gateway_integration.integration ]
}

resource "aws_api_gateway_method_settings" "proxy_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  method_path = "*/*"
  stage_name  = aws_api_gateway_stage.rest_api_stage.stage_name

  settings {
    data_trace_enabled = true
    metrics_enabled = true
    logging_level = "INFO"
  }
}

# api docs
resource "aws_api_gateway_integration" "s3_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  http_method             = aws_api_gateway_method.api_docs_proxy_method.http_method
  resource_id             = aws_api_gateway_resource.api_docs_proxy_rest_api_resource.id
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  connection_type         = "INTERNET"
  uri                     = "http://${aws_s3_bucket_website_configuration.swagger_bucket_website.website_endpoint}/{proxy}"
  timeout_milliseconds = 29000
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  depends_on = [ aws_s3_bucket.swagger_bucket ]
}
resource "aws_api_gateway_method_response" "api_docs_proxy_method_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_docs_proxy_rest_api_resource.id
  http_method = aws_api_gateway_method.api_docs_proxy_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "api_docs_proxy_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_docs_proxy_rest_api_resource.id
  http_method = aws_api_gateway_method.api_docs_proxy_method.http_method
  status_code = aws_api_gateway_method_response.api_docs_proxy_method_response.status_code

  depends_on = [ aws_api_gateway_integration.s3_integration ]
}
