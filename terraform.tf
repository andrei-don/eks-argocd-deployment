terraform {
  required_version = "1.9.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
  backend "s3" {
    bucket         = "eks-playground-my-tf-state"
    key            = "state"
    region         = "eu-west-1"
    dynamodb_table = "eks-playground-infra-state-locks"
  }
}