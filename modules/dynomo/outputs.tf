output "dynamo_db_arn"{
    value = aws_dynamodb_table.table.arn
}

output "dynomo_table_name" {
  value=aws_dynamodb_table.table.name
}