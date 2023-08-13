resource "aws_instance" "nfs" {
  ami                  = var.ubuntu
  instance_type        = "c5.xlarge" //"c5.xlarge"
  key_name             = "nfs-key"
  subnet_id            = module.vpc.intra_subnets[0]
  iam_instance_profile = aws_iam_instance_profile.ssm-profile.name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  //private_ip = "172.50.xx.xx"
  vpc_security_group_ids = [aws_security_group.data-sg.id]
  root_block_device {
    volume_size           = 1500
    volume_type           = "gp3"
    iops                  = 3000
    encrypted             = true
    delete_on_termination = true
    tags = merge(local.common_tags, {
      Name = format("%s-%s-nfs-EBS", var.project, var.environment),
    })
  }
  tags = merge(local.common_tags, {
    Name                = format("%s-%s-nfs", var.project, var.environment),
    start-stop-schedule = false,
    OS                  = "Ubuntu",
    Backup              = "DailyBackup"
  })
}