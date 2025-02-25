resource "aws_iam_role" "iam_for_lambda" {
  for_each = var.stack
  name     = join("-", ["role-lambda", each.key])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_sns_logging_policy" {
  for_each    = var.stack
  name        = "LambdaSNSLoggingPolicy"
  description = "Permite que a Lambda publique no SNS e faça logs no CloudWatch."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.email_alerts[each.key].arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "lambda_sns_logging_attach" {
  for_each   = var.stack
  name       = join("-", ["lambda_sns_logging_attach", each.key])
  roles      = [aws_iam_role.iam_for_lambda[each.key].name]
  policy_arn = aws_iam_policy.lambda_sns_logging_policy[each.key].arn
}
