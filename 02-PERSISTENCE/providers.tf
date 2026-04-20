terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "jquinterov.seminario2"
    key     = "laboratorio1/persistence/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "Seminario2"
  }

  required_providers {
    aws = { source = "hashicorp/aws"
    version = "~> 6.0" }
  }
}

provider "aws" { 
  region = var.aws_region
  profile = var.aws_profile
}