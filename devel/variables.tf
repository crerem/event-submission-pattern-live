variable "AWS_REGION" {
  default     = "us-west-1"
  description = "aws region"
}

variable "profile" {
  default = "default"
}


variable "APP_NAME" {
  default     = "SG12-Serverless"
  description = "application name"
}

variable "ENV" {
  default     = "devel"
  description = "enviroment"
}


variable "TF_CLOUD_ORGANIZATION" {
  default     = "curlycloud"
  description = "terraform organization"
}
  
variable "TF_CLOUD_WORKSPACE" {
  default     = "event-submission-pattern-devel"
  description = "terrafrom serverless workspace devel "
}  

variable "AWS_SECRET_ACCESS_KEY" {
  default     = "AWS_SECRET_ACCESS_KEY"
  description = "need to setup this in terraform cloud workspace"
}

variable "AWS_ACCESS_KEY_ID" {
  default     = "AWS_ACCESS_KEY_ID"
  description = "need to setup this in terraform cloud workspace"
}