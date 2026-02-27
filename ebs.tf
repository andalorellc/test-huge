# EBS: standalone, count, for_each, literal/local/variable size, type variants

# Literal size
resource "aws_ebs_volume" "data" {
  availability_zone = "${var.aws_region}a"
  size              = 100
  type              = "gp3"

  tags = {
    Name = "${local.name_prefix}-data-volume"
  }
}

# Isolated local (Case 2)
resource "aws_ebs_volume" "logs" {
  availability_zone = "${var.aws_region}a"
  size              = local.ebs_size_isolated
  type              = "gp3"

  tags = {
    Name = "${local.name_prefix}-logs-volume"
  }
}

# Variable
resource "aws_ebs_volume" "shared_size" {
  availability_zone = "${var.aws_region}a"
  size              = var.ebs_volume_size
  type              = "gp3"

  tags = {
    Name = "${local.name_prefix}-shared-volume"
  }
}

# count = literal
resource "aws_ebs_volume" "counted" {
  count             = 5
  availability_zone = var.azs[count.index % length(var.azs)]
  size              = 50
  type              = "gp2"

  tags = {
    Name = format("%s-vol-%02d", local.name_prefix, count.index)
  }
}

# count = var
resource "aws_ebs_volume" "scaled" {
  count             = var.instance_count
  availability_zone  = var.azs[0]
  size              = var.ebs_volume_size
  type              = "gp3"

  tags = {
    Name = "${local.name_prefix}-scaled-${count.index}"
  }
}

# for_each = set
resource "aws_ebs_volume" "per_az" {
  for_each          = toset(var.azs)
  availability_zone = each.key
  size              = 30
  type              = "io1"
  iops              = 1000

  tags = {
    Name = "${local.name_prefix}-${each.key}"
  }
}

# Type gp2
resource "aws_ebs_volume" "gp2" {
  availability_zone = "${var.aws_region}a"
  size              = 200
  type              = "gp2"

  tags = {
    Name = "${local.name_prefix}-gp2"
  }
}
