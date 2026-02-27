# App module: instances + EBS (value flow from module input)

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = length(var.subnet_ids) > 0 ? var.subnet_ids[count.index % length(var.subnet_ids)] : null

  tags = {
    Name        = "${var.app_name}-${count.index}"
    Environment = var.environment
  }
}

resource "aws_ebs_volume" "data" {
  count             = var.instance_count
  availability_zone = var.availability_zone
  size              = var.ebs_size
  type              = "gp3"

  tags = {
    Name = "${var.app_name}-vol-${count.index}"
  }
}
