resource "aws_cloudwatch_event_rule" "step-function-trigger" {
  name = "${var.app_name}-${terraform.workspace}-step-function-rule"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail" : {
      "eventSource" : ["s3.amazonaws.com"],
      "eventName" : ["PutObject"],
      "requestParameters" : {
        "bucketName" : ["${aws_s3_bucket.resultbucket.id}"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "step_function_target" {
  rule      = aws_cloudwatch_event_rule.step-function-trigger.name
  arn       = aws_sfn_state_machine.sfn_state_machine.arn
  target_id = "${var.app_name}-${terraform.workspace}-step-function-target"
  role_arn  = aws_iam_role.eventbridgerole.arn
}
