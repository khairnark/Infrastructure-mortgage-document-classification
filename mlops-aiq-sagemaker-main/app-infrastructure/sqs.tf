resource "aws_sqs_queue" "ALLEQUEUE" {
  name                       = "${var.app_name}-${terraform.workspace}-sqs-queue"
  visibility_timeout_seconds = 240
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-sqs-queue"
    Environment = terraform.workspace
  }
}

resource "aws_sqs_queue" "VALIDATEQUEUE" {
  name                       = "${var.app_name}-${terraform.workspace}-sqs-queue-validate"
  visibility_timeout_seconds = 240
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-sqs-queue-validate"
    Environment = terraform.workspace
  }
}

resource "aws_sqs_queue" "INVALIDATEQUEUE" {
  name = "${var.app_name}-${terraform.workspace}-sqs-queue-invalidate"
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-sqs-queue-invalidate"
    Environment = terraform.workspace
  }
}