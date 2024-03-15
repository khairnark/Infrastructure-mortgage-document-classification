terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.32"
    }
  }
}

provider "aws" {
  region = var.primary_region
}

module "databricks_resource" {
  source                = "modules/databricks-resources"
  primary_region        = var.primary_region
  acount_id             = var.acount_id
  external_id           = var.external_id
  data_bucket_name      = var.data_bucket_name
  data_bucket2_name     = var.data_bucket2_name
  project               = var.project
  environment           = var.environment
  organization          = var.organization
  count_bucket_ems3paas = var.count_bucket_ems3paas
  kms_account_name      = var.kms_account_name
}