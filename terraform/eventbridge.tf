resource "aws_cloudwatch_event_bus" "event_bus" {
  name = "${var.env}-${var.name}-event-bus"
}

resource "aws_cloudwatch_event_rule" "persist_phone_numbers_rule" {
  name        = "${var.env}-${var.name}-task-rule"
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name

  event_pattern = jsonencode({
    source = ["api"]
    detail-type = ["api.task.created"]
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.persist_phone_numbers_rule.name
  target_id = "SendToLambda"
  arn = aws_lambda_function.create_task_lambda.arn
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name

  depends_on = [ aws_cloudwatch_event_rule.persist_phone_numbers_rule ]
}
