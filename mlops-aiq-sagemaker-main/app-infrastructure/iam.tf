data "aws_iam_policy" "EC2SSMAccess" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy" "app-logs-policy" {
  name        = "${var.app_name}-logs-policy-${terraform.workspace}"
  path        = "/"
  description = "Policy granting permission to CloudWatch logs"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogGroup",
        "logs:TagResource",
        "logs:UntagResource",
        "logs:ListTagsForResource",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource" : [
        "arn:aws:logs:*:*:*"
      ]
    }]
  })
}

resource "aws_iam_policy" "app-cross-account-policy" {
  name        = "${var.app_name}-cross-account-connect-policy-${terraform.workspace}"
  path        = "/"
  description = "Policy for accessing Connct API"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : "sts:AssumeRole",
      "Resource" : "arn:aws:iam::${local.linked_account}:role/connect${terraform.workspace}-${var.app_name}-cross-account"
    }]
  })
}

resource "aws_iam_role" "app-logs-role" {
  name                  = "${var.app_name}-logs-role-${terraform.workspace}"
  force_detach_policies = true
  path                  = "/"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "ec2.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app-logs-profile" {
  name_prefix = "${var.app_name}-logs-profile-${terraform.workspace}-"
  role        = aws_iam_role.app-logs-role.name
}

resource "aws_iam_role_policy_attachment" "admin-policy" {
  role       = aws_iam_role.app-logs-role.name
  policy_arn = data.aws_iam_policy.EC2SSMAccess.arn
}

resource "aws_iam_policy_attachment" "app-logs-policy-attachment" {
  name       = "${var.app_name}-logs-policy-attachment-${terraform.workspace}"
  roles      = [aws_iam_role.app-logs-role.name]
  policy_arn = aws_iam_policy.app-logs-policy.arn
}

resource "aws_iam_policy" "lambda_role_policy" {
  name        = "lambda_access-policy"
  description = "IAM Policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl" 
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        },
        {
          "Action": [
            "autoscaling:Describe*",
            "cloudwatch:*",
            "logs:*",
            "sns:*",
            "lambda:*",
            "textract:*",
            "comprehend:*",
            "sqs:*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
  ]
}
  EOF
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.app_name}-lambdarole-${terraform.workspace}"
  path               = "/"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda-policy-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_role_policy.arn
}

resource "aws_iam_policy" "comprehend-iam-policy" {
  name        = "${var.app_name}-${terraform.workspace}-amazon-comprehend-policy"
  description = "Comprehend IAM Policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "*",                                             
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "*",                                             
      "Effect": "Allow"
    }
  ]
}
  EOF
}

resource "aws_iam_role" "comprehend-role" {
  name               = "${var.app_name}-${terraform.workspace}-comprehend-role"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "comprehend.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "comprehend-policy-attach" {
  role       = aws_iam_role.comprehend-role.name
  policy_arn = aws_iam_policy.comprehend-iam-policy.arn
}

resource "aws_iam_role" "textract-role" {
  name               = "${var.app_name}-${terraform.workspace}-textract-role-name"
  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "textract.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}
EOF
}

resource "aws_iam_policy" "textract-role-policy" {
  name        = "${var.app_name}-${terraform.workspace}-textract-role-policy"
  description = "Provides access to sns and s3"
  path        = "/"
  policy      = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "",
			"Effect": "Allow",
			"Action": [
				"sns:*",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
			],
			"Resource": "*"
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "textract_policy_attachment" {
  role       = aws_iam_role.textract-role.name
  policy_arn = aws_iam_policy.textract-role-policy.arn
}


resource "aws_iam_role" "step_function_role" {
  name               = "${var.app_name}-${terraform.workspace}-stepfunction-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal":{
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "StepFunctionAssumeRole"
      }
    ] 
  }
  EOF
}

# AWS Step Function role policy
resource "aws_iam_policy" "step_function_policy" {
  name        = "${var.app_name}-${terraform.workspace}-stepfunction-role-policy"
  description = "Step Function Access Policy"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "stepfunction_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}

resource "aws_iam_role" "eventbridgerole" {
  assume_role_policy = data.aws_iam_policy_document.eventbridgepolicy.json
  #   assume_role_policy = <<EOF
  # {
  #   "Version" : "2012-10-17",
  #   "Statement" : [
  #     {
  #       "Effect" : "Allow",
  #       "Principal" : {
  #         "Service" : "events.amazonaws.com"
  #       },
  #       "Action" : "sts:AssumeRole"
  #     }
  #   ]
  # }
  # EOF
}

# Create an IAM policy for Eventbridge to be able to start a Step Function execution
# resource "aws_iam_policy" "eventbridgepolicy" {
#   policy = <<EOF
# {
#   "Version" : "2012-10-17",
#   "Statement" : [
#     {
#       "Effect" : "Allow",
#       "Action" : [
#         "states:StartExecution"
#       ],
#       "Resource" : "${aws_sfn_state_machine.sfn_state_machine.arn}"
#     }
#   ]
# }
# EOF
# }

data "aws_iam_policy_document" "eventbridgepolicy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "states.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }
}

# Create an IAM policy to enable Step Function State Machine to push logs to CloudWatch logs
resource "aws_iam_policy" "StateMachineLogDeliveryPolicy" {
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
      ],
      "Resource" : "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "StateMachinePolicyAttachment" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.StateMachineLogDeliveryPolicy.arn
}