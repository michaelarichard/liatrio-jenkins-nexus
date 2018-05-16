
# CANNOT INTERPOLATE VARS HERE
terraform {
  backend "s3" {
    bucket = "stormpath-terraform-state"
    key    = "liatrio/interview.tfstate"
    region = "us-west-2"
  }
}

# CAN INTERPOLATE VARS HERE
provider "aws" {
  region = "us-west-2"
# profile/role, etc.
}
