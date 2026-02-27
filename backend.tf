terraform {
  backend "s3" {
    bucket = "123456789012-test-deployments"
    key    = "${var.environment}/${var.service}/terraform.tfstate"
    region = "us-east-1"
  }
}
