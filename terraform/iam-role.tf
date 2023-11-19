resource "aws_iam_role" "api_gw_iam_role" {
  name               = "${var.name}-api-gw-iam-role"
  assume_role_policy = data.aws_iam_policy_document.api_gw_assume_role.json

  tags = var.tags
}

resource "aws_iam_role" "main_lambda_role" {
  name               = "${var.name}-main-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = var.tags
}
