resource "aws_vpc" "main-vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = var.vpc-name
  }
}

resource "aws_flow_log" "flow-logs" {
  log_destination      = aws_cloudwatch_log_group.prod-vpc-flowlogs.arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.cloudwatch-role.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main-vpc.id
}

resource "aws_cloudwatch_log_group" "prod-vpc-flowlogs" {
  name = format("flowlogs/%s", var.vpc-name)
  kms_key_id = var.kms-arn
  retention_in_days = 0
}

resource "aws_iam_role" "cloudwatch-role" {
  name_prefix               = var.log-group-name ? var.log-group-name : format("%s-flowlog-cwatch-role", var.vpc-name)
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    name = format("%s-flowlog-cwatch-role", var.vpc-name)
  }
}

resource "aws_iam_role_policy" "cloudwatch-logstream" {
  name_prefix   = format("%s-cwatch-log-policy", var.vpc-name)
  role   = aws_iam_role.cloudwatch-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
/*
module "kms-cwatch-flowlogs" {
  source = "../modules/aws-kms"
  alias_name = format("%s-cwatch-logs-kms",var.Environment)
  description = "KMS CMK for vpc flowlogs cloudwatch"
  environment = var.Environment
  product_domain = "CWatch"
  region = var.region
  key_policy = true
}
*/