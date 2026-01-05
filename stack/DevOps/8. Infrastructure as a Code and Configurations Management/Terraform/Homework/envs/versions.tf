terraform {
  required_version = "~> 1.13.0"

  # save Terraform state (resources) in S3
  backend "s3" {
    bucket = "tfstate-hw"
    key = "tf-homework/terraform.tfstate"
    region = "eu-central-1"     
    encrypt = false
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
    http = {
      source = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

