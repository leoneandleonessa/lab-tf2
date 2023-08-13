# EC2 1
resource "aws_instance" "webserver" {
  ami                         = ""              #CAHNGE
  instance_type               = "c5.large"      //"m5.xlarge" #CHANGE
  key_name                    = "webserver-key" #CHANGE
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = false
  //  private_ip = "172.50.xx.xx"

  vpc_security_group_ids = [aws_security_group.application-sg.id]

  iam_instance_profile = aws_iam_instance_profile.ssm-profile.name
  lifecycle { ignore_changes = [vpc_security_group_ids, instance_state] }
  root_block_device {
    volume_size           = 15    #CHANGE
    volume_type           = "gp3" #CHANGE
    encrypted             = true
    delete_on_termination = true
    tags = {
      Name        = upper(format("%s-%s-webserver-EBS", var.project, var.environment))
      ENVIRONMENT = var.environment
    }
  }
  tags = {
    Name        = format("%s-%s-webserver", var.project, var.environment),
    ENVIRONMENT = var.environment
    OS          = "Ubuntu",
    Backup      = "DailyBackup"
  }
}

// Create Listener Https

resource "aws_lb" "tempo-webserver-alb" {
  name               = format("%s-%s-webserver-alb", var.project, var.environment)
  internal           = false
  load_balancer_type = "application"
  security_groups = [
  aws_security_group.alb-sg.id]
  subnets                    = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  enable_deletion_protection = false
  idle_timeout               = 60
  tags                       = local.common_tags
  drop_invalid_header_fields = true

  access_logs {
    bucket = "tempo-elb-log" //aws_s3_bucket.lb_logs.bucket
    // prefix  = "test-lb"
    enabled = true
  }


}
# Production APP Listener
resource "aws_lb_listener" "tempo-webserver-listener-http" {
  load_balancer_arn = aws_lb.tempo-webserver-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}



//TOBE
resource "aws_lb_listener" "tempo-webserver-listener-https" {
  load_balancer_arn = aws_lb.tempo-webserver-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
  certificate_arn   = "arn:aws:acm:ap-southeast-3:861764390995:certificate/8840eff2-26e2-4040-9847-e6444c4fe7ce"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tempo-webserver-tg.arn
  }
}

resource "aws_lb_target_group" "tempo-webserver-tg" {
  name     = format("%s-%s-webserver-tg", var.environment, var.project)
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id //aws_vpc.vpc.id
  health_check {
    protocol            = "HTTP"
    matcher             = "200,302,301"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_target_group_attachment" "tempo-webserver-tg-attach" {
  target_group_arn = aws_lb_target_group.tempo-webserver-tg.arn
  target_id        = aws_instance.webserver.id
  port             = 80
}


module "webserver-asg" {

  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  name    = format("%s-%s-webserver-asg", var.project, var.environment)

  # Launch configuration
  lc_name              = format("%s-%s-webserver-lc", var.project, var.environment)
  image_id             = "" #CHANGE
  instance_type        = "c5.large"
  security_groups      = [aws_security_group.alb-sg.id, aws_security_group.application-sg.id]
  termination_policies = ["OldestInstance"]
  root_block_device = [
    {
      volume_size           = 15
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  ]
  enable_monitoring = true
  # Auto scaling group
  asg_name                  = format("%s-%s-webserver-asg", var.project, var.environment)
  vpc_zone_identifier       = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  health_check_type         = "ELB"
  min_size                  = 0
  max_size                  = 4
  desired_capacity          = 0
  wait_for_capacity_timeout = 0
  iam_instance_profile      = aws_iam_instance_profile.ssm-profile.name
  #Target Group
  target_group_arns = [aws_lb_target_group.tempo-webserver-tg.arn]
  tags_as_map       = local.common_tags
}


#Automatic Scale
resource "aws_autoscaling_policy" "tempo-webserver-scale-out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.webserver-asg.this_autoscaling_group_name

}
resource "aws_autoscaling_policy" "tempo-webserver-scale-in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.webserver-asg.this_autoscaling_group_name
}


resource "aws_cloudwatch_metric_alarm" "tempo-webserver-cpu-above" {
  alarm_name          = format("%s-%s-tempo-webserver-autoscale-cpu-above", var.project, var.environment)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = format("%s-tempo-webserver-autoscale-cpu-above", var.project)
  alarm_actions = [
    aws_autoscaling_policy.tempo-webserver-scale-out.arn,
    aws_sns_topic.alert-sns-topic.arn
  ]
  dimensions = {
    AutoScalingGroupName = module.webserver-asg.this_autoscaling_group_name
  }
}
resource "aws_cloudwatch_metric_alarm" "tempo-webserver-autoscale-cpu-below" {
  alarm_name          = format("%s-tempo-webserver-autoscale-cpu-below", var.project)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = format("%s-tempo-webserver-autoscale-cpu-below", var.project)
  alarm_actions = [
    aws_autoscaling_policy.tempo-webserver-scale-in.arn,
    aws_sns_topic.alert-sns-topic.arn
  ]
  dimensions = {
    AutoScalingGroupName = module.webserver-asg.this_autoscaling_group_name
  }
}
