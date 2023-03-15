variable "ENVIROMENT" {
  default     = "production"
  description = "enviroment"
}

variable "APP_NAME" {
  default     = "production"
  description = "enviroment"
}


variable "MAIN_LAMBDA_INVOKE_ARN" {
    type=string
}

variable "SQS_URI" {
    type=string
}
variable "SQS_NAME" {
    type=string
}
variable "SQS_ARN" {
    type=string
}

variable "AWS_REGION" {
    type=string
}
