resource "aws_sns_topic" "user_updates" {
  name   = "${var.ENVIROMENT}-user-updates-topic"
}
