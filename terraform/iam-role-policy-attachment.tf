resource "aws_iam_role_policy_attachment" "api_gw_policy_attachment" {
  role       = aws_iam_role.api_gw_iam_role.id
  policy_arn = aws_iam_policy.api_gw_policy.arn
}

resource "aws_iam_role_policy_attachment" "main_base_policy_attachment" {
  role = aws_iam_role.main_lambda_role.id
  policy_arn = aws_iam_policy.lambda_base_policy.arn
}

resource "aws_iam_role_policy_attachment" "main_policy_attachment" {
  role = aws_iam_role.main_lambda_role.id
  policy_arn = aws_iam_policy.main_policy.arn
}
