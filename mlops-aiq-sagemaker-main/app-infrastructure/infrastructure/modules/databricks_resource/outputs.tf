output "databricks_config_bucket" {
  value = aws_s3_bucket.databricks_config_bucket.bucket
}

output "databricks_log_bucket" {
  value = aws_s3_bucket.databricks_log_bucket.bucket
}

output "databricks_library_bucket" {
  value = aws_s3_bucket.databricks_lib_bucket.bucket
}

output "databricks_deployment_role_arn" {
  value = aws_iam_role.databricks_deployment_role.arn
}

output "databricks_cluster_role_arn" {
  value = aws_iam_role.databricks_cluster_role.arn
}

output "databricks_cluster_role_name" {
  value = aws_iam_role.databricks_cluster_role.name
}

output "databricks_cluster_instance_profile_arn" {
  value = aws_iam_instance_profile.databricks_cluster_profile.arn
}

output "databricks_cluster_instance_profile_name" {
  value = aws_iam_instance_profile.databricks_cluster_profile.name
}