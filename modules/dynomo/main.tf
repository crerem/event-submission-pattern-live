resource "aws_dynamodb_table" "table" {
  name           = "${var.APP_NAME}-${var.ENVIROMENT}-dynamodb-Orders"
  billing_mode   = "PAY_PER_REQUEST"

  hash_key       = "orderId"
  range_key      = "orderOwner"

  attribute {
    name = "orderId"
    type = "S"
  }

  attribute {
    name = "orderOwner"
    type = "S"
  }

  tags = {
    Name        = "${var.APP_NAME}-${var.ENVIROMENT}-dynamodb-table"
    Environment = "production"
  }
}
