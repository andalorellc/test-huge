variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (set via TF_VAR_environment or -var)"
  type        = string
}

variable "service" {
  description = "Service name (set via TF_VAR_service or -var)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}
