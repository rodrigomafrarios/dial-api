resource "aws_api_gateway_rest_api" "rest_api" {
  name                         = "${var.name}-api"
  disable_execute_api_endpoint = false

  tags = var.tags
}

resource "aws_api_gateway_account" "rest_api_account" {
  cloudwatch_role_arn = aws_iam_role.api_gw_iam_role.arn

  depends_on = [ aws_iam_policy.api_gw_policy, aws_iam_role.api_gw_iam_role ]
}

resource "aws_api_gateway_resource" "proxy_rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy_rest_api_resource.id
  http_method   = "ANY"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_resource" "api_docs_rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "api-docs"
}

resource "aws_api_gateway_resource" "api_docs_proxy_rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_resource.api_docs_rest_api_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_docs_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_docs_proxy_rest_api_resource.id
  http_method =  "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}
# Deploy each time using temporary stage
# https://github.com/hashicorp/terraform/issues/6613

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "temporary"
  stage_description = "${md5(
    format("%s%s",
      file("${path.module}/api-gateway.tf"),
      file("${path.module}/apigateway-integration.tf"),
    )
  )}"
  depends_on = [
    aws_api_gateway_method.proxy_method,
    aws_api_gateway_method.api_docs_proxy_method,
    aws_api_gateway_integration.integration,
    aws_api_gateway_integration.s3_integration
  ]
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "${var.env}"
  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = "{ 'requestId':'$context.requestId', 'ip': '$context.identity.sourceIp', 'caller':'$context.identity.caller', 'user':'$context.identity.user','requestTime':'$context.requestTime', 'httpMethod':'$context.httpMethod','resourcePath':'$context.resourcePath', 'status':'$context.status','protocol':'$context.protocol', 'responseLength':'$context.responseLength' }"
  }

  tags = var.tags
}
