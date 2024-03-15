variable "primary_region" {
  description = "The primary region (to orchestrate things which happen once)"
}

variable "project" {
  description = "Name of project this cluster is for (default: `AIQ Analyzer`)"
}

variable "environment" {
  description = "ame of environment this cluster is targeting (default: `dev`, 'stg', 'prod')"
}

variable "organization" {
  description = "ICE Mortgage Technology"
}

variable "acount_id" {
  description = "Databricks account id"
}

variable "external_id" {
  description = "Databricks external id"
}

variable "data_bucket_name" {
  description = "S3 bucket that contains Ellie Mae data "
}

variable "data_bucket2_name" {
  description = "S3 bucket that contains Ellie Mae data "
}

variable "count_bucket" {
  description = "Count to determine if bucket needs to be maintained by TF"
}

variable "kms_account_name" {
  description = "account that allows for cross-account KMS"
  type        = map(string)
  default = {
    dev  = "182125784941"
    prod = "659053808757"
  }
}