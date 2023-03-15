provider "aws" {

  region = var.AWS_REGION

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }

 required_version = ">= 1.1.0"
  cloud {
    organization = var.TF_CLOUD_ORGANIZATION

    workspaces {
        name= var.TF_CLOUD_WORKSPACE
    }
  } 
  
}

