module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"
  # insert the 14 required variables here
  name                             = format("%s-%s-VPC", var.project, var.environment)
  cidr                             = var.cidr
  enable_dns_hostnames             = true
  enable_dhcp_options              = true
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]
  azs                              = ["ap-southeast-3a", "ap-southeast-3b"]
  public_subnets                   = [var.Public_Subnet_AZ1, var.Public_Subnet_AZ2]
  private_subnets                  = [var.Private_APP_AZ1, var.Private_APP_AZ2]
  intra_subnets                    = [var.Private_Intra_AZ1, var.Private_Intra_AZ2]
  # Nat Gateway
  enable_nat_gateway = true
  # Reuse NAT IPs
  reuse_nat_ips         = true
  external_nat_ip_ids   = [aws_eip.eip-nat-tempo.id, aws_eip.eip-nat2-tempo.id]
  public_subnet_suffix  = "web"
  private_subnet_suffix = "app"
  intra_subnet_suffix   = "data"
  tags                  = local.common_tags
}

resource "aws_eip" "eip-nat-tempo" {
  vpc = true
  tags = merge(local.common_tags, {
    Name = format("%s-production-EIP", var.project)
  })
}

resource "aws_eip" "eip-nat2-tempo" {
  vpc = true
  tags = merge(local.common_tags, {
    Name = format("%s-production-EIP2", var.project)
  })
}
#
#resource "aws_subnet" "subnet-db-1a" {
# vpc_id      = module.vpc.vpc_id
#  cidr_block = var.Private_Intra_AZ1
#  availability_zone = format("%sa", var.aws_region)
#}
#
#resource "aws_subnet" "subnet-db-1b" {
# vpc_id      = module.vpc.vpc_id
#  cidr_block = var.Private_Intra_AZ2
#  availability_zone = format("%sb", var.aws_region)
#}
