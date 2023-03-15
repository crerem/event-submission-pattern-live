/*
Once the REST API is configured, the aws_api_gateway_deployment resource 
can be used along with the aws_api_gateway_stage resource to publish the REST API.*/

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.APP_NAME}-rest-api-${var.ENVIROMENT}"
  description = "Api Gateway that will POST to a SQS"
}


/*
* Declaring the resource
*/

resource "aws_api_gateway_resource" "api" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "example-resource"
  rest_api_id = aws_api_gateway_rest_api.api.id
}


/*
*Declare the deployment
*/

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api.id,
      aws_api_gateway_method.api.id,
      aws_api_gateway_integration.api.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_integration.api
  ]
}




/*
* Declaring the stage
*/
resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "${var.APP_NAME}-${var.ENVIROMENT}-stage"
}



/*
* Validator
*/
resource "aws_api_gateway_request_validator" "api" {
  rest_api_id           = aws_api_gateway_rest_api.api.id
  name                  = "${var.APP_NAME}-${var.ENVIROMENT}-payload-validator"
  validate_request_body = true
}



/*
* Input model for the api
*/

resource "aws_api_gateway_model" "api" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "${var.ENVIROMENT}PayloadValidator"
  description  = "validate the json body content conforms to the below spec"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "required": [ "orderId", "orderOwner"]
}
EOF
}


/*
* Api Gateway Integration
*/
resource "aws_api_gateway_integration" "api" {
  http_method             = aws_api_gateway_method.api.http_method
  resource_id             = aws_api_gateway_resource.api.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = aws_iam_role.api-gateway-to-sqs-role.arn
  uri                     = "arn:aws:apigateway:${var.AWS_REGION}:sqs:path/${var.SQS_NAME}"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}




/*
* Integration response
*/

resource "aws_api_gateway_integration_response" "answer200" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.api.id
  http_method       = aws_api_gateway_method.api.http_method
  status_code       = aws_api_gateway_method_response.answer200.status_code
  selection_pattern = "^2[0-9][0-9]" // regex pattern for any 200 message that comes back from SQS

  response_templates = {
    "application/json" = "{\"message\": \"is done!\"}"
  }

  depends_on = [aws_api_gateway_integration.api]
}


/*
*
*/
resource "aws_api_gateway_method_response" "answer200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.api.id}"
  http_method = "${aws_api_gateway_method.api.http_method}"
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}

/*
*
*/
resource "aws_api_gateway_method" "api" {
  authorization        = "none"
  http_method          = "POST"
  resource_id          = aws_api_gateway_resource.api.id
  rest_api_id          = aws_api_gateway_rest_api.api.id
  request_validator_id = aws_api_gateway_request_validator.api.id
  request_models = {
    "application/json" = "${aws_api_gateway_model.api.name}"
  }
}





/*
* Role to be assumend by APi Gateway when posting to SQS
*/

resource "aws_iam_role" "api-gateway-to-sqs-role" {
  name = "api-gateway-to-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

}

/*
* Policy for the role
*/

resource "aws_iam_policy" "api-gateway-to-sqs-role-policy" {
  name = "api-gateway-to-sqs-role-policy"

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
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:SendMessageBatch",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:CreateQueue",
          "sqs:ListQueueTags",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:SetQueueAttributes"
        ],
        "Resource": "${var.SQS_ARN}"
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


resource "aws_iam_role_policy_attachment" "api" {
  role       = aws_iam_role.api-gateway-to-sqs-role.name
  policy_arn = aws_iam_policy.api-gateway-to-sqs-role-policy.arn
}