# VPC endpoints: gateway vs interface, for_each, count, optional attribute

# Gateway (literal service)
resource "aws_vpc_endpoint" "s3" {
  count        = var.create_vpc ? 1 : 0
  vpc_id       = local.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${local.name_prefix}-s3-endpoint"
  }
}

# Interface - private_dns_enabled = true
resource "aws_vpc_endpoint" "ecr" {
  count             = (var.create_vpc) && !(var.environment == "dev" && var.service == "test-huge") ? 1 : 0
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = local.subnet_ids

  tags = {
    Name = "${local.name_prefix}-ecr"
  }
}

# Interface - private_dns_enabled = false
resource "aws_vpc_endpoint" "logs" {
  count             = var.create_vpc ? 1 : 0
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = false
  subnet_ids        = local.subnet_ids

  tags = {
    Name = "${local.name_prefix}-logs"
  }
}

# for_each over services
resource "aws_vpc_endpoint" "per_service" {
  for_each          = var.create_vpc ? { for s in var.endpoint_services : s => s } : {}
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type = "Interface"
  subnet_ids        = local.subnet_ids

  tags = {
    Name = "${local.name_prefix}-${each.key}"
  }
}

# count
resource "aws_vpc_endpoint" "extra" {
  count             = var.create_vpc ? var.endpoint_count_per_service : 0
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids        = local.subnet_ids

  tags = {
    Name = format("%s-ec2-%02d", local.name_prefix, count.index)
  }
}
