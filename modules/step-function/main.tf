resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine"
  role_arn = aws_iam_role.role.arn

  definition = <<EOF
{
  "Comment": "A simple invoice processing workflow",
  "StartAt": "Process Invoice",
  "States": {
    "Process Invoice": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${var.PROCESSING_LAMBDA_ARN}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "Notify"
    },
    "Notify": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message.$": "$",
        "TopicArn": "${var.SNS_ARN}"
      },
      "Next": "Save to Dynamo",
      "ResultPath": null
    },
    "Save to Dynamo": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${var.SAVE_TO_DYNOMO_LAMBDA_ARN}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
EOF
}




/*
* Declare the Role
*/

resource "aws_iam_role" "role" {
  name               = "${var.APP_NAME}-StepFunctions-role"
  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "states.amazonaws.com"
          }
        }
      ]
    })
}





/*
* Policy for the role
*/

resource "aws_iam_policy" "policy" {
  name = "step_function_policy"

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
        "Action": "lambda:InvokeFunction",
        "Resource": "${var.SAVE_TO_DYNOMO_LAMBDA_ARN}:$LATEST"
      },
      {
        "Effect": "Allow",
        "Action": "lambda:InvokeFunction",
        "Resource": "${var.PROCESSING_LAMBDA_ARN}:$LATEST"
      },
      {
            "Effect": "Allow",
            "Action": [
                "sns:Publish",
                "sns:Subscribe",
                "sns:Unsubscribe"
            ],
            "Resource": [
                "${var.SNS_ARN}",
                "${var.SNS_ARN}:*"
            ]
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
