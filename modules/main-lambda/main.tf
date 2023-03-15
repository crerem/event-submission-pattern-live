data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/hello.py"
  output_path = "${path.module}/hello.zip"
}


resource "aws_lambda_function" "main_lambda" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.zip.output_path)

  function_name = var.FUNCTION_NAME
  role          = aws_iam_role.role.arn
  runtime       = "python3.8"
  handler       = "hello.lambda_handler"
  timeout       = 10

  environment {
    variables = {
      STEP_FUNCTION_ARN = var.STEP_FUNCTION_ARN
    }
  }

}



/*
* Event Source Mapping
*/
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = var.SQS_ARN
  function_name    = aws_lambda_function.main_lambda.arn
}



//declare role
resource "aws_iam_role" "role" {
  name = "${var.APP_NAME}-lambda-role"
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
  name = "api-gateway-to-sqs-role-policy_new"

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
      },
      {
        "Effect": "Allow",
        "Action": [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource": "${var.SQS_ARN}"
      },
      {
        "Effect": "Allow",
        "Action": [
           "sqs:DeleteMessage",
              "states:UpdateMapRun",
              "states:CreateActivity",
              "states:UpdateStateMachine",
              "states:DeleteStateMachine",
              "states:StopExecution",
              "states:StartSyncExecution",
              "states:DeleteActivity",
              "states:StartExecution",
              "states:GetActivityTask",
              "states:CreateStateMachine"
        ],
        "Resource": "${var.STEP_FUNCTION_ARN}"
      },
      {
        "Effect": "Allow",
        "Action": "sqs:ListQueues",
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





resource "aws_lambda_alias" "alias_dev" {
  name             = "dev"
  description      = "dev"
  function_name    = aws_lambda_function.main_lambda.arn
  function_version = "$LATEST"
}






resource "aws_cloudwatch_log_group" "convert_log_group" {
  name = "/aws/lambda/${aws_lambda_function.main_lambda.function_name}"
}
