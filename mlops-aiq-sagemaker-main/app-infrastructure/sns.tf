resource "aws_sns_topic" "snstopic" {
  name = "${var.app_name}-${terraform.workspace}-sns-topic"
}

# Allow EventBridge to publish to the SNS topic
resource "aws_sns_topic_policy" "aiq-snstopicpolicy" {
  arn    = aws_sns_topic.snstopic.arn
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSEventsPermission",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.snstopic.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.step-function-trigger.arn}"
        }
      }
    }
  ]
}
POLICY
}