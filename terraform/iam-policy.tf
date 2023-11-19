resource "aws_iam_policy" "api_gw_policy" {
  name = "${var.name}-base-api-gw-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:AssociateKmsKey",
          "logs:DescribeLogGroups",
          "logs:DisassociateKmsKey",
          "logs:ListTagsLogGroup",
          "logs:PutRetentionPolicy"
        ],
        "Resource" : [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:*/*",
        ]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "lambda_base_policy" {
  name = format("%s-base-function-policy", var.name)
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:AssociateKmsKey",
          "logs:DescribeLogGroups",
          "logs:DisassociateKmsKey",
          "logs:ListTagsLogGroup",
          "logs:PutRetentionPolicy",
          "logs:CreateLogGroup"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/*:*:*"
      },
      {
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:PublishLayerVersion",
          "lambda:GetLayerVersion",
          "lambda:ListLayerVersions",
          "lambda:ListLayers",
          "lambda:AddLayerVersionPermission"
        ],
        "Resource" : ["*"]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "main_policy" {
  name = "${var.name}-main-function-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Action": ["dynamodb:Query", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:GetItem", "dynamodb:DeleteItem"],
        "Effect": "Allow",
        "Resource": [
          aws_dynamodb_table.task_table.arn,
          "${aws_dynamodb_table.task_table.arn}/index/*"
        ]
      },
      {
        "Action": [
            "kms:Decrypt",
            "kms:GenerateDataKey",
            "kms:ReEncryptFrom",
            "kms:CreateGrant",
            "kms:DescribeKey"
        ],
        "Effect": "Allow",
        "Resource": [
            aws_kms_key.dynamodb_key.arn
        ]
      }
    ]
  })

  tags = var.tags
}
