terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Single instance (test-huge minimal setup)
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.service
    Environment = var.environment
  }
}
