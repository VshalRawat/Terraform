terraform {
  backend "s3" {
    bucket = "vishal-s3-bucket15"
    key = "vishal.tfstate"
    region = "eu-north-1"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}