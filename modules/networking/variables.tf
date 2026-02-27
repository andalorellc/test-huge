variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "tags" {
  type    = map(string)
  default = {}
}
