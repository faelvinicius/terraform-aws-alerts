resource "aws_lambda_function" "rds_snapshot_shared" {
  for_each      = var.stack
  filename      = each.value["filename"]
  function_name = join("_", ["lambda", "rds_snapshot_shared", each.key])
  role          = aws_iam_role.iam_for_lambda[each.key].arn
  handler       = each.value["handler"]

  source_code_hash = data.archive_file.rds_snapshot_shared[each.key].output_base64sha256

  runtime = each.value["runtime"]

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.email_alerts[each.key].arn
    }
  }
}

data "archive_file" "rds_snapshot_shared" {
  for_each    = var.stack
  type        = each.value["type"]
  source_file = "${path.module}/code/rds_snapshot_shared/lambda_function.py"
  output_path = each.value["output_path"]
}

resource "aws_cloudwatch_event_rule" "rds_snapshot_shared" {
  for_each = var.stack
  name        = join("_", ["rds_snapshot_shared", each.key])
  description = "Captura eventos de compartilhamento de snapshot de rds entre contas."

  event_pattern = jsonencode({
    source      = ["aws.rds"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["rds.amazonaws.com"]
      eventName   = ["ModifyDBSnapshotAttribute"]
    }
  })
}

resource "aws_cloudwatch_event_target" "rds_snapshot_shared" {
  for_each = var.stack
  rule      = aws_cloudwatch_event_rule.rds_snapshot_shared[each.key].name
  target_id = each.value["target_id"]
  arn       = aws_lambda_function.rds_snapshot_shared[each.key].arn
}
