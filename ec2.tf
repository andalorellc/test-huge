# EC2: single, count (literal/var/conditional), for_each, ASG, launch template, spot
# Value flow: literal, variable, data source, resource ref, ternary, format()

# Single instance (no count/for_each)
resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.service
    Environment = var.environment
  }
}

# Instance - literal in block
resource "aws_instance" "bastion" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name = "my-app"
  }
}

# Instance - data source
resource "aws_instance" "from_ami" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = {
    Name = "${var.service}-${var.environment}"
  }
}

# Instance - count = literal (small)
resource "aws_instance" "web" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = format("%s-%s-%02d", var.service, var.environment, count.index)
  }
}

# Instance - count = var
resource "aws_instance" "workers" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = {
    Name = "${var.service}-${count.index}"
  }
}

# Instance - count conditional
resource "aws_instance" "optional" {
  count         = var.create_vpc ? 1 : 0
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${local.name_prefix}-optional"
  }
}

# Instance - for_each = set
resource "aws_instance" "per_az" {
  for_each      = toset(var.azs)
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${var.service}-${each.key}"
  }
}

# Instance - for_each = local
resource "aws_instance" "from_local" {
  for_each      = local.env_config
  ami           = var.ami_id
  instance_type = each.value.instance_type

  tags = {
    Name = "${each.key}-${each.value.instance_type}"
  }
}

# Instance - map lookup
resource "aws_instance" "api" {
  ami           = var.ami_id
  instance_type = var.instance_type_map["api"]

  tags = {
    Name = "${var.service}-api"
  }
}

# Instance - ternary
resource "aws_instance" "with_subnet" {
  count         = var.create_vpc ? 2 : 0
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.use_private ? local.subnet_ids[0] : (length(aws_subnet.public) > 0 ? aws_subnet.public[0].id : null)

  tags = {
    Name = "${local.name_prefix}-sub-${count.index}"
  }
}

# Instance - lifecycle
resource "aws_instance" "lifecycle_ignore" {
  ami           = var.ami_id
  instance_type = var.instance_type

  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "${local.name_prefix}-lifecycle"
  }
}

# Instance - depends_on
resource "aws_instance" "after_nat" {
  count         = var.create_vpc ? 1 : 0
  ami           = var.ami_id
  instance_type = var.instance_type

  depends_on = [aws_nat_gateway.main]

  tags = {
    Name = "${local.name_prefix}-after-nat"
  }
}

# Launch template
resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }
}

# Launch template - count
resource "aws_launch_template" "per_tier" {
  count         = 5
  name_prefix   = "${local.name_prefix}-tier-${count.index}-"
  image_id      = var.ami_id
  instance_type = var.instance_type_map["web"]

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = format("%s-tier-%02d", local.name_prefix, count.index) }
  }
}

# ASG
resource "aws_autoscaling_group" "app" {
  name_prefix        = "${local.name_prefix}-asg-"
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = local.subnet_ids

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-asg"
    propagate_at_launch = true
  }
}

# ASG - for_each
resource "aws_autoscaling_group" "per_az" {
  for_each            = toset(var.azs)
  name_prefix         = "${local.name_prefix}-${each.key}-"
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  min_size            = 0
  max_size            = 5
  desired_capacity    = 1
  vpc_zone_identifier = [for s in aws_subnet.private : s.id if s.availability_zone == each.key]

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-${each.key}"
    propagate_at_launch = true
  }
}

# Spot instance request
resource "aws_spot_instance_request" "batch" {
  count             = 2
  ami               = var.ami_id
  instance_type     = var.instance_type
  wait_for_fulfillment = true

  tags = {
    Name = "${local.name_prefix}-spot-${count.index}"
  }
}

# Spot - single
resource "aws_spot_instance_request" "worker" {
  ami               = data.aws_ami.amazon_linux.id
  instance_type     = "t3.small"
  wait_for_fulfillment = true

  tags = {
    Name = "${local.name_prefix}-spot-worker"
  }
}
