# fetching current account id
###############
data "aws_caller_identity" "current" {}

data "archive_file" "upload" {
  type        = "zip"
  source_file = "../app-infrastructure/lambda_files/upload.py"
  output_path = "../app-infrastructure/lambda_files/upload.zip"
}
resource "aws_lambda_function" "upload" {
  filename         = "../app-infrastructure/lambda_files/upload.zip"
  function_name    = "${var.app_name}-${terraform.workspace}-upload-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "upload.lambda_handler"
  source_code_hash = data.archive_file.upload.output_base64sha256

  runtime     = "python3.9"
  timeout     = 180
  description = "Upload"
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-upload-lambda"
    Environment = terraform.workspace
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "upload" {
  name              = "/aws/lambda/${terraform.workspace}aws-${var.app_name}-${aws_lambda_function.upload.function_name}"
  retention_in_days = 30
}

data "archive_file" "validate" {
  type        = "zip"
  source_file = "../app-infrastructure/lambda_files/validate.py"
  output_path = "../app-infrastructure/lambda_files/validate.zip"
}

resource "aws_lambda_function" "validate" {
  filename         = "../app-infrastructure/lambda_files/validate.zip"
  function_name    = "${var.app_name}-${terraform.workspace}-validate-file-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "validate.lambda_handler"
  source_code_hash = data.archive_file.validate.output_base64sha256

  runtime     = "python3.9"
  timeout     = 120
  description = "validate lambda function"
  environment {
    variables = {
      invalidqueue = "${aws_sqs_queue.INVALIDATEQUEUE.id}"
      resultbucket = "${aws_s3_bucket.resultbucket.id}"
      invalidsns   = "${aws_sns_topic.snstopic.arn}"
    }
  }
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-validate-file-lambda"
    Environment = terraform.workspace
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "validate" {
  name              = "/aws/lambda/${terraform.workspace}aws-${var.app_name}-${aws_lambda_function.validate.function_name}"
  retention_in_days = 30
}

data "archive_file" "textract" {
  type        = "zip"
  source_file = "../app-infrastructure/lambda_files/textract.py"
  output_path = "../app-infrastructure/lambda_files/textract.zip"
}

resource "aws_lambda_function" "textract" {
  filename         = "../app-infrastructure/lambda_files/textract.zip"
  function_name    = "${var.app_name}-${terraform.workspace}-textract-lambda-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "textract.lambda_handler"
  source_code_hash = data.archive_file.textract.output_base64sha256

  runtime     = "python3.9"
  timeout     = 120
  description = "textract lambda function"

  environment {
    variables = {
      allqueue = "${aws_sqs_queue.VALIDATEQUEUE.id}"
    }
  }
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-textract-lambda-function"
    Environment = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "extract" {
  name              = "/aws/lambda/${terraform.workspace}aws-${var.app_name}-${aws_lambda_function.textract.function_name}"
  retention_in_days = 30
}

data "archive_file" "comprehend" {
  type        = "zip"
  source_file = "../app-infrastructure/lambda_files/comprehend.py"
  output_path = "../app-infrastructure/lambda_files/comprehend.zip"
}

resource "aws_lambda_function" "comprehend" {
  filename         = "../app-infrastructure/lambda_files/comprehend.zip"
  function_name    = "${var.app_name}-${terraform.workspace}-comprehend-file-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "comprehend.lambda_handler"
  source_code_hash = data.archive_file.comprehend.output_base64sha256

  runtime     = "python3.9"
  timeout     = 120
  description = "comprehend lambda function"
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-comprehend-file-lambda"
    Environment = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "comprehend" {
  name              = "/aws/lambda/${terraform.workspace}aws-${var.app_name}-${aws_lambda_function.comprehend.function_name}"
  retention_in_days = 30
}


resource "aws_lambda_event_source_mapping" "queue" {
  batch_size       = 10
  enabled          = true
  event_source_arn = aws_sqs_queue.VALIDATEQUEUE.arn
  function_name    = aws_lambda_function.validate.arn
}

resource "aws_lambda_permission" "bucketpermission-comprehend" {
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.comprehend.arn
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = aws_s3_bucket.resultbucket.arn
}

resource "aws_lambda_permission" "bucketpermission-extract" {
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.textract.arn
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = aws_s3_bucket.resultbucket.arn
}


