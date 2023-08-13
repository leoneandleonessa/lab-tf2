resource "aws_instance" "mongodb_cluster01" {
  ami                         = var.ubuntu      #CAHNGE
  instance_type               = "c5.large"      //"c5.2xlarge" #CHANGE
  key_name                    = "mongodb01-key" #CHANGE
  subnet_id                   = module.vpc.intra_subnets[0]
  associate_public_ip_address = false
  // private_ip = "172.70.31.146"

  vpc_security_group_ids = [aws_security_group.mongodb_cluster01-sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm-profile.name
  lifecycle { ignore_changes = [vpc_security_group_ids, instance_state] }
  root_block_device {
    volume_size           = 115   #CHANGE
    volume_type           = "gp3" #CHANGE
    encrypted             = true
    delete_on_termination = true
    tags = {
      Name        = upper(format("%s-%s-mongodb01-EBS", var.project, var.environment))
      ENVIRONMENT = var.environment
    }
  }
  tags = {
    Name        = format("%s-%s-mongodb01", var.project, var.environment),
    ENVIRONMENT = var.environment
    Backup      = "DailyBackup"
  }
}