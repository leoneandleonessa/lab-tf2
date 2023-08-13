output "vpc-id" {
  value = aws_vpc.main-vpc.id
}

output "iam-role-arn" {
  value = aws_iam_role.cloudwatch-role.arn
}