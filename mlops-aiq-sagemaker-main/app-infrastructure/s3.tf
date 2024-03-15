resource "aws_s3_bucket" "resultbucket" {
  bucket = "${var.app_name}-${terraform.workspace}-${data.aws_caller_identity.current.account_id}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  acl = "private"
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-${data.aws_caller_identity.current.account_id}"
    Environment = terraform.workspace
  }
  depends_on = [
    aws_lambda_function.comprehend,
    aws_lambda_function.textract
  ]
}

resource "aws_s3_bucket_notification" "resultbucket_notification" {
  bucket = aws_s3_bucket.resultbucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.comprehend.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "result/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.textract.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".png"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.textract.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.textract.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".pdf"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.textract.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".csv"
  }

}

resource "aws_s3_bucket_public_access_block" "result-block-public" {
  bucket                  = aws_s3_bucket.resultbucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket" "resultbucket1" {
  bucket = "${var.app_name}-${terraform.workspace}-outputbucket"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  acl = "private"
  tags = {
    Name        = "${var.app_name}-${terraform.workspace}-outputbucket"
    Environment = terraform.workspace
  }
}