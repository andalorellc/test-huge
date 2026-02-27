variable "app_name" { type = string }
variable "environment" { type = string }
variable "instance_count" {
  type    = number
  default = 3
}
variable "instance_type" {
  type    = string
  default = "t3.small"
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}
variable "ebs_size" {
  type    = number
  default = 50
}
