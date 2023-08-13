locals {
  cwatch-alarm-instanceid-linux = [aws_instance.bastion-host.id, aws_instance.webserver.id,
    aws_instance.mongodb_cluster01.id, aws_instance.mongodb_cluster02.id,
  aws_instance.mongodb_cluster03.id, aws_instance.nfs.id]
}




module "rc-cwatch-alarm-linux" {
  count           = length(local.cwatch-alarm-instanceid-linux)
  source          = "./modules/aws-cloudwatch-alarm"
  sns-topic-arn   = aws_sns_topic.alert-sns-topic.arn
  memory          = true
  disk            = true
  alarm-threshold = "85"
  instance-id     = element(local.cwatch-alarm-instanceid-linux, count.index)
}
