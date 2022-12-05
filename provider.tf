
# provider.tf

# Specify the provider and access details
provider "aws" {
  #shared_credentials_file = "$HOME/.aws/credentials"
  #profile                 = "default"
  region                  = var.aws_region
}

terraform {

  backend "s3" {
    region = var.aws_region
  }
}