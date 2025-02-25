resource "aws_sns_topic" "email_alerts" {
  for_each    = var.stack
  name_prefix = each.key
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  for_each               = var.stack
  topic_arn              = aws_sns_topic.email_alerts[each.key].arn
  protocol               = each.value["protocol"]
  endpoint               = each.value["endpoint"]
  endpoint_auto_confirms = each.value["endpoint_auto_confirms"]
}