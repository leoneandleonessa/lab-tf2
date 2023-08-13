resource "aws_instance" "mongodb_cluster02" {
  ami                         = var.ubuntu      #CAHNGE
  instance_type               = "c5.large"      //"c5.2xlarge" #CHANGE
  key_name                    = "mongodb02-key" #CHANGE
  subnet_id                   = module.vpc.intra_subnets[0]
  associate_public_ip_address = false
  //  private_ip = "172.50.xx.xx"

  vpc_security_group_ids = [aws_security_group.mongodb_cluster02-sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm-profile.name
  lifecycle { ignore_changes = [vpc_security_group_ids, instance_state] }
  root_block_device {
    volume_size           = 115   #CHANGE
    volume_type           = "gp3" #CHANGE
    encrypted             = true
    delete_on_termination = true
    tags = {
      Name        = upper(format("%s-%s-mongodb02-EBS", var.project, var.environment))
      ENVIRONMENT = var.environment
    }
  }
  tags = {
    Name        = format("%s-%s-mongodb02", var.project, var.environment),
    ENVIRONMENT = var.environment
    Backup      = "DailyBackup"
  }
}