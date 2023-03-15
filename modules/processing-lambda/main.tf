data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/processing_lamnbda.py"
  output_path = "${path.module}/processing_lamnbda.zip"
}


resource "aws_lambda_function" "processing_lamnbda" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.zip.output_path)

  function_name = var.FUNCTION_NAME
  role          = aws_iam_role.role.arn
  runtime       = "python3.8"
  handler       = "processing_lamnbda.lambda_handler"
  timeout       = 10

 

}





//declare role
resource "aws_iam_role" "role" {
  name = "${var.APP_NAME}-lambda-processing-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
/*
* Policy for the role
*/

resource "aws_iam_policy" "policy" {
  name = "lambda-processing-role-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource": "*"
      }
    ]
}
EOF
}

/*
*  Attach policty to Role
*/


resource "aws_iam_role_policy_attachment" "policy_to_role" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}







