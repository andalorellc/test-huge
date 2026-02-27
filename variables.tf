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
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "Default EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "instance_type_map" {
  description = "Instance type by role (map lookup pattern)"
  type        = map(string)
  default = {
    web    = "t3.medium"
    api    = "t3.large"
    worker = "t3.small"
  }
}

# Scale variables (tune to reach ~10k resources across all deployments)
variable "instance_count" {
  description = "Number of root-level instances (count = var.instance_count)"
  type        = number
  default     = 15
}

variable "app_count" {
  description = "Number of app module instances (module with count)"
  type        = number
  default     = 50
}

variable "app_per_az_count" {
  description = "App modules per AZ (for_each over azs)"
  type        = number
  default     = 4
}

variable "nat_count" {
  description = "NAT gateways (literal or var)"
  type        = number
  default     = 3
}

variable "create_nat" {
  description = "Create optional NAT (count conditional)"
  type        = bool
  default     = true
}

variable "create_vpc" {
  description = "Create VPC (count conditional)"
  type        = bool
  default     = true
}

variable "create_firewalls" {
  description = "Create network firewalls (conditional for_each)"
  type        = bool
  default     = true
}

variable "ebs_volume_size" {
  description = "Default EBS volume size (GB)"
  type        = number
  default     = 100
}

variable "azs" {
  description = "Availability zones (for_each set)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "endpoint_services" {
  description = "VPC endpoint service names (for_each)"
  type        = list(string)
  default     = ["s3", "ecr.api", "logs", "ec2", "sts"]
}

variable "asg_min_size" {
  type    = number
  default = 0
}

variable "asg_max_size" {
  type    = number
  default = 10
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "use_private" {
  description = "Use private subnet (ternary pattern)"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "web_ingress_ports" {
  description = "Ports for dynamic ingress block"
  type        = list(number)
  default     = [80, 443]
}

variable "instances_per_app_module" {
  description = "Instances per app module (inside module)"
  type        = number
  default     = 3
}

variable "firewall_count" {
  type    = number
  default = 5
}

variable "endpoint_count_per_service" {
  type    = number
  default = 2
}
