# // Create state machine for step function
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name       = "${var.app_name}-${terraform.workspace}-state-machine"
  role_arn   = aws_iam_role.step_function_role.arn
  definition = <<EOF
{
    "Comment": "Invoke AWS Lambda from AWS Step Functions",
    "StartAt": "Upload",
    "States": {
        "Upload": {
            "Comment": "Uploading file to s3 bucket",
            "Type": "Task",
            "Resource": "${aws_lambda_function.upload.arn}",
            "Next": "Convert"
        },
        "Convert": {
            "Comment": "Convert file to csv and send in a queue",
            "Type": "Task",
            "Resource": "${aws_lambda_function.validate.arn}",
            "Next": "Extract"
        },
        "Extract": {
            "Comment": "It helps in extracting the document by word or line",
            "Type": "Task",
            "Resource": "${aws_lambda_function.textract.arn}",
            "Next": "Comprehend"
        },
        "Comprehend": {
            "Comment": "It classifies the document based on the file",
            "Type": "Task",
            "Resource": "${aws_lambda_function.comprehend.arn}",
            "End": true
        }
    }
}
EOF
  depends_on = [aws_lambda_function.upload, aws_lambda_function.validate, aws_lambda_function.comprehend, aws_lambda_function.textract]

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.MySFNLogGroup.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}

# Create an Log group for the Step Function
resource "aws_cloudwatch_log_group" "MySFNLogGroup" {
  name_prefix       = "/aws/${var.app_name}/${terraform.workspace}/vendedlogs/states/StateMachine"
  retention_in_days = 60
}