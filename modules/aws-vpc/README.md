Example:

module "riski-test-vpc" {
  source   = "./modules/aws-vpc"
  cidr     = "192.168.0.0/16"
  vpc-name = "poko"
  kms-arn = module.kms-cwatch-flowlogs.key_arn
}

module "kms-cwatch-flowlogs" {
  source = "../modules/aws-kms"
  alias_name = format("%s-cwatch-logs-kms",var.Environment)
  description = "KMS CMK for vpc flowlogs cloudwatch"
  environment = var.Environment
  product_domain = "CWatch"
  region = var.region
  key_policy = true
}
