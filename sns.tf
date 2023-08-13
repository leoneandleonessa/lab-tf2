resource "aws_sns_topic" "alert-sns-topic" {
  name = format("%s-resource-alert-topic", var.project)
  /*
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.alarms_email}"
  }
*/
}