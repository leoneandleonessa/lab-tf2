resource "aws_instance" "bastion-host" {
  ami                  = "ami-021fb2b73ff1efc96"
  instance_type        = "c5.large"
  key_name             = "bastion-new-key"
  subnet_id            = module.vpc.public_subnets[0]
  iam_instance_profile = aws_iam_instance_profile.ssm-profile.name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  //private_ip = "172.50.11.138"
  //public_ip = "108.136.163.249"
  vpc_security_group_ids = [aws_security_group.bastion-host-sg.id]
  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    iops                  = 3000
    encrypted             = true
    delete_on_termination = true
    tags = merge(local.common_tags, {
      Name = format("%s-%s-bastion-EBS", var.project, var.environment),
    })
  }
  tags = merge(local.common_tags, {
    Name                = format("%s-%s-bastion", var.project, var.environment),
    start-stop-schedule = false,
    OS                  = "AmazonLinux",
    Backup              = "DaiBackup"
  })
}
