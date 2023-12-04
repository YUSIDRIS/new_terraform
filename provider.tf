terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.27.0"
    }
  }
}
provider "aws" {
  region     = "us-west-2"
  shared_credentials_files = ["~/.aws/credentiatls"]
  profile                  = "default"
}