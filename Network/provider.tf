terraform {
  backend "s3" {
    bucket = "idristerraformstate1"
    key    = "Network.statefile"
    region = "us-west-2"
  }
}

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
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}