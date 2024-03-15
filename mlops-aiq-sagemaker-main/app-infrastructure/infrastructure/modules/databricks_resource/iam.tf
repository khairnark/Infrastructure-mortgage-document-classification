# Reference:
# https://confluence.elliemae.io/display/DATA/DataBricks+Deployment+automation?focusedCommentId=86560106#DataBricksDeploymentautomation-VPCmodification
# https://docs.databricks.com/administration-guide/account-settings/aws-accounts.html#use-a-cross-account-role

#
# IAM resources
#

# The IAM role for Databricks control plane

resource "aws_iam_role" "databricks_deployment_role" {
  name = "${var.project}-${var.environment}-control-role"

  #provider = "provider.aws"
  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::${var.acount_id}:root"
			},
			"Action": "sts:AssumeRole",
			"Condition": {
				"StringEquals": {
					"sts:ExternalId": "${var.external_id}"
				}
			}
		}
	]
}
EOF
}

resource "aws_iam_policy" "databricks_deployment_policy" {
  name   = "${var.project}-${var.environment}-deployment-policy"
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Sid": "Stmt1403287045000",
           "Effect": "Allow",
           "Action": [
               "ec2:AssociateDhcpOptions",
               "ec2:AssociateRouteTable",
               "ec2:AttachInternetGateway",
               "ec2:AttachVolume",
               "ec2:AuthorizeSecurityGroupEgress",
               "ec2:AuthorizeSecurityGroupIngress",
               "ec2:CancelSpotInstanceRequests",
               "ec2:CreateDhcpOptions",
               "ec2:CreateInternetGateway",
               "ec2:CreateKeyPair",
               "ec2:CreatePlacementGroup",
               "ec2:CreateRoute",
               "ec2:CreateSecurityGroup",
               "ec2:CreateSubnet",
               "ec2:CreateTags",
               "ec2:CreateVolume",
               "ec2:CreateVpc",
               "ec2:CreateVpcPeeringConnection",
               "ec2:DeleteInternetGateway",
               "ec2:DeleteKeyPair",
               "ec2:DeletePlacementGroup",
               "ec2:DeleteRoute",
               "ec2:DeleteRouteTable",
               "ec2:DeleteSecurityGroup",
               "ec2:DeleteSubnet",
               "ec2:DeleteVolume",
               "ec2:DeleteVpc",
               "ec2:DescribeAvailabilityZones",
               "ec2:DescribeInstanceStatus",
               "ec2:DescribeInstances",
               "ec2:DescribePlacementGroups",
               "ec2:DescribePrefixLists",
               "ec2:DescribeReservedInstancesOfferings",
               "ec2:DescribeRouteTables",
               "ec2:DescribeSecurityGroups",
               "ec2:DescribeSpotInstanceRequests",
               "ec2:DescribeSpotPriceHistory",
               "ec2:DescribeSubnets",
               "ec2:DescribeVolumes",
               "ec2:DescribeVpcs",
               "ec2:DetachInternetGateway",
               "ec2:ModifyVpcAttribute",
               "ec2:RequestSpotInstances",
               "ec2:RevokeSecurityGroupEgress",
               "ec2:RevokeSecurityGroupIngress",
               "ec2:RunInstances",
               "ec2:TerminateInstances"
           ],
           "Resource": [
               "*"
           ]
       },
       {
           "Effect": "Allow",
           "Action": [
               "iam:CreateServiceLinkedRole",
               "iam:PutRolePolicy"
           ],
           "Resource": "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
           "Condition": {
               "StringLike": {
                   "iam:AWSServiceName": "spot.amazonaws.com"
               }
           }
       },
       {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": "${aws_iam_role.databricks_cluster_role.arn}"
        }]
}
EOF
}


resource "aws_iam_role_policy_attachment" "databricks_deployment_policy_attach" {
  role       = aws_iam_role.databricks_deployment_role.name
  policy_arn = aws_iam_policy.databricks_deployment_policy.arn
}


resource "aws_s3_bucket" "databricks_config_bucket" {
  region = var.primary_region
  bucket = "em-${var.project}-${var.environment}-${var.primary_region}-config"
  acl    = "private"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Grant Databricks Access",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.acount_id}:root"
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::em-${var.project}-${var.environment}-${var.primary_region}-config/*",
        "arn:aws:s3:::em-${var.project}-${var.environment}-${var.primary_region}-config"
      ]
    }
  ]
}
POLICY
}



resource "aws_s3_bucket" "databricks_log_bucket" {
  region = var.primary_region
  bucket = "em-${var.project}-${var.environment}-${var.primary_region}-log"
  acl    = "private"

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = ""
    #prefix  = "log/"
    tags {
      rule      = "log"
      autoclean = "true"
    }


    #S3 One Zone-IA, Infrequent Access
    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }



    #Amazon Glacier, a secure, durable, and extremely low-cost storage service for data archiving
    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "DatabricksAuditLogs",
  "Statement": [
    {
      "Sid": "PutAuditLogs",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::090101015318:role/DatabricksAuditLogs-WriterRole-VV4KJWX4FRIK"
      },
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::em-${var.project}-${var.environment}-${var.primary_region}-log/auditlog/*"
    },
    {
      "Sid": "DenyNotContainingFullAccess",
      "Effect": "Deny",
      "Principal": {
        "AWS": "arn:aws:iam::090101015318:role/DatabricksAuditLogs-WriterRole-VV4KJWX4FRIK"
      },
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::em-${var.project}-${var.environment}-${var.primary_region}-log/auditlog/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY
}

# IAM role for Databricks cluster, use to access S3 data
resource "aws_iam_role" "databricks_cluster_role" {
  name = "${var.project}-${var.environment}-data-role"
  #provider = "provider.aws"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "databricks_cluster_profile" {
  name = "${var.project}-${var.environment}-data-profile"
  path = "/"
  role = aws_iam_role.databricks_cluster_role.name
}

# Attach policy to allow Databricks cluster access custom data S3 bucket and cross-account kms
resource "aws_iam_policy" "databricks_cluster_data_policy" {
  name = "${var.project}-${var.environment}-cluster-data-policy"

  policy = <<EOF
  
  {
    "Version": "2012-10-17",
    "Statement": [{
        "Action": [
            "s3:GetObject"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${var.data_bucket_name}/*",
          "arn:aws:s3:::${var.data_bucket2_name}/*"
        ]
    }, {
        "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${var.data_bucket_name}",
          "arn:aws:s3:::${var.data_bucket2_name}"
        ]
    },
    {
      "Sid": "Allow to use the key",
      "Effect": "Allow",
      "Action": [
        "kms:Encript",
        "kms:Decrypt",
        "kms:ReEncript",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ]
      "Resource": "arn:aws:kms:us-west-2:${var.kms_account_name[var.environment]}:key/*"
    }]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "databricks_cluster_data_policy_attach" {
  role       = aws_iam_role.databricks_cluster_role.name
  policy_arn = aws_iam_policy.databricks_cluster_data_policy.arn
}

# Attach policy to allow Datbricks cluster access custom S3 bucket, that is used to store the log files
resource "aws_iam_policy" "databricks_cluster_log_policy" {
  name   = "${var.project}-${var.environment}-cluster-log-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.databricks_log_bucket.bucket}/*"
        ]
    }, {
        "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.databricks_log_bucket.bucket}"
        ]
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "databricks_cluster_log_policy_attach" {
  role       = aws_iam_role.databricks_cluster_role.name
  policy_arn = aws_iam_policy.databricks_cluster_log_policy.arn
}

# # Encrypted data bucket for EMS3 Paas to store claims
# resource "aws_s3_bucket" "ems3paas_data_bucket" {
#   count  = var.count_bucket_ems3paas
#   region = var.primary_region
#   bucket = "em-ds-${var.environment}-ems3paas-${var.primary_region}-data"
#   acl    = "private"
# }

data "aws_s3_bucket" "ems3pass_data" {
  bucket = "em-ds-${var.environment}-ems3paas-${var.primary_region}-data"
}

# Libarry  bucket for Security Agents, and Machine Learning libraries
resource "aws_s3_bucket" "databricks_lib_bucket" {
  region        = var.primary_region
  bucket        = "em-${var.project}-${var.environment}-${var.primary_region}-library"
  acl           = "private"
  force_destroy = true
}

# Attach policy to allow Databricks cluster access library S3 bucket, that is used to store the libraries
resource "aws_iam_policy" "databricks_cluster_lib_policy" {
  name   = "${var.project}-${var.environment}-cluster-lib-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.databricks_lib_bucket.bucket}/*",
          "arn:aws:s3:::${data.aws_s3_bucket.ems3pass_data.bucket}/*"
        ]
    }, {
        "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.databricks_lib_bucket.bucket}",
          "arn:aws:s3:::${data.aws_s3_bucket.ems3pass_data.bucket}"
        ]
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "databricks_cluster_lib_policy_attach" {
  role       = aws_iam_role.databricks_cluster_role.name
  policy_arn = aws_iam_policy.databricks_cluster_lib_policy.arn
}