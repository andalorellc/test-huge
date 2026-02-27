# VPC and subnets (resource reference, module output patterns)

resource "aws_vpc" "main" {
  count      = var.create_vpc ? 1 : 0
  cidr_block = var.vpc_cidr

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_subnet" "public" {
  count             = var.create_vpc ? length(var.azs) : 0
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone  = var.azs[count.index]

  tags = {
    Name = format("%s-public-%02d", local.name_prefix, count.index)
  }
}

resource "aws_subnet" "private" {
  count             = var.create_vpc ? length(var.azs) : 0
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.azs[count.index]

  tags = {
    Name = format("%s-private-%02d", local.name_prefix, count.index)
  }
}

# Outputs consumed by other resources (module-like pattern from root)
locals {
  vpc_id     = var.create_vpc ? aws_vpc.main[0].id : null
  subnet_ids = var.create_vpc ? aws_subnet.private[*].id : []
}
