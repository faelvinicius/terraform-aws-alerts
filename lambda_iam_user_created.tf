resource "aws_lambda_function" "iam_user_created" {
  for_each      = var.stack
  filename      = each.value["filename"]
  function_name = join("_", ["lambda", "iam_user_created", each.key])
  role          = aws_iam_role.iam_for_lambda[each.key].arn
  handler       = each.value["handler"]

  source_code_hash = data.archive_file.iam_user_created[each.key].output_base64sha256

  runtime = each.value["runtime"]

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.email_alerts[each.key].arn
    }
  }
}

data "archive_file" "iam_user_created" {
  for_each    = var.stack
  type        = each.value["type"]
  source_file = "${path.module}/code/iam_user_created/lambda_function.py"
  output_path = each.value["output_path"]
}

resource "aws_cloudwatch_event_rule" "iam_user_created" {
  for_each = var.stack
  name        = join("_", ["iam_user_created", each.key])
  description = "Captura eventos de criação de usuários IAM via CloudTrail."

  event_pattern = jsonencode({
    source      = ["aws.iam"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
      eventName   = ["CreateUser"]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_user_created" {
  for_each = var.stack
  rule      = aws_cloudwatch_event_rule.iam_user_created[each.key].name
  target_id = each.value["target_id"]
  arn       = aws_lambda_function.iam_user_created[each.key].arn
}
