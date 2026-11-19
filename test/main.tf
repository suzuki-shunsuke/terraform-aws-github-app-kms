terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "app" {
  source   = "../"
  app_slug = "example-app"
  imported = false
  conditions = [
    {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:example-org/*:*"]
    }
  ]
}

module "without_role" {
  source      = "../"
  app_slug    = "example-app-2"
  imported    = true
  create_role = false
  signer_arns = ["arn:aws:iam::123456789012:role/example"]
}
