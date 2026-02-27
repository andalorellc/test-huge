# Subdir module (source = "./modules/stack//vpc")
data "aws_region" "current" {}
output "vpc_id" { value = "vpc-stack-${data.aws_region.current.id}" }
output "subnet_ids" { value = [] }
