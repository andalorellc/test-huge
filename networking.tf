# EIPs, NAT gateways (literal, local, count, for_each, depends_on)

resource "aws_eip" "nat" {
  count  = var.create_vpc ? var.nat_count : 0
  domain = "vpc"

  tags = {
    Name = format("%s-nat-eip-%02d", local.name_prefix, count.index)
  }

  depends_on = [aws_vpc.main]
}

resource "aws_eip" "with_local" {
  domain = local.eip_domain

  tags = {
    Name = "${local.name_prefix}-local-eip"
  }
}

# NAT gateway - single
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat[0].id
  subnet_id     = local.subnet_ids[0]

  tags = {
    Name = "${local.name_prefix}-nat-main"
  }

  depends_on = [aws_vpc.main, aws_subnet.public]
}

# NAT gateway - count = literal (small)
resource "aws_nat_gateway" "extra" {
  count         = var.create_vpc ? 2 : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = local.subnet_ids[count.index % length(local.subnet_ids)]

  tags = {
    Name = format("%s-nat-extra-%02d", local.name_prefix, count.index)
  }
}

# NAT gateway - count = var
resource "aws_nat_gateway" "scaled" {
  count         = var.create_vpc ? min(var.nat_count, length(aws_eip.nat)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = local.subnet_ids[count.index % length(local.subnet_ids)]

  tags = {
    Name = format("%s-nat-scaled-%02d", local.name_prefix, count.index)
  }
}

# NAT gateway - count conditional
resource "aws_nat_gateway" "conditional" {
  count         = var.create_nat && var.create_vpc ? 1 : 0
  allocation_id = aws_eip.with_local.id
  subnet_id     = length(local.subnet_ids) > 0 ? local.subnet_ids[0] : null

  tags = {
    Name = "${local.name_prefix}-nat-conditional"
  }
}

# NAT gateway - for_each over AZs
resource "aws_nat_gateway" "per_az" {
  for_each      = var.create_vpc ? toset(var.azs) : toset([])
  allocation_id = aws_eip.nat[index(var.azs, each.key)].id
  subnet_id     = aws_subnet.public[index(var.azs, each.key)].id

  tags = {
    Name = "${local.name_prefix}-nat-${each.key}"
  }
}

# Security group - inline and reference, dynamic block
resource "aws_security_group" "web" {
  count       = var.create_vpc ? 1 : 0
  name_prefix = "${local.name_prefix}-web-"
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = var.web_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "${local.name_prefix}-web"
  }
}

resource "aws_security_group" "app" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    Name = "${local.name_prefix}-app"
  }
}
