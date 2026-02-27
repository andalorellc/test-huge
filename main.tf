# Provider and module invocations (many shapes: count, for_each, same source different names)

provider "aws" {
  region = var.aws_region
}

# Local VPC module (single)
module "base_vpc" {
  source   = "./modules/vpc"
  vpc_name = "${local.name_prefix}-base"
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
  tags     = local.common_tags
}

# App module with count (many instances of same module)
module "app_web" {
  count          = var.app_count
  source         = "./modules/app"
  app_name       = "${local.name_prefix}-web-${count.index}"
  environment    = var.environment
  instance_count = var.instances_per_app_module
  instance_type  = var.instance_type_map["web"]
  subnet_ids     = local.subnet_ids
  availability_zone = var.azs[count.index % length(var.azs)]
  ebs_size       = var.ebs_volume_size
}

# App module with different name (same source)
module "app_worker" {
  count          = 30
  source         = "./modules/app"
  app_name       = "${local.name_prefix}-worker-${count.index}"
  environment    = var.environment
  instance_count = 4
  subnet_ids     = local.subnet_ids
  availability_zone = var.azs[0]
}

module "app_api" {
  count          = 20
  source         = "./modules/app"
  app_name       = "${local.name_prefix}-api-${count.index}"
  environment    = var.environment
  instance_count = 5
  instance_type  = var.instance_type_map["api"]
  subnet_ids     = local.subnet_ids
  availability_zone = var.azs[count.index % length(var.azs)]
}

# App module with for_each (set)
module "app_per_az" {
  for_each       = local.azs_set
  source         = "./modules/app"
  app_name       = "${local.name_prefix}-az-${each.key}"
  environment    = var.environment
  instance_count = var.app_per_az_count
  subnet_ids     = local.subnet_ids
  availability_zone = each.key
}

# App module with for_each (map from local)
module "app_env" {
  for_each       = local.env_config
  source         = "./modules/app"
  app_name       = "${local.name_prefix}-${each.key}"
  environment    = var.environment
  instance_count = each.value.replicas
  instance_type  = each.value.instance_type
  subnet_ids     = local.subnet_ids
  availability_zone = var.azs[0]
}

# Networking module with count
module "networking" {
  count      = var.create_vpc ? 25 : 0
  source     = "./modules/networking"
  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids
  region     = var.aws_region
  tags       = merge(local.common_tags, { Tier = "tier-${count.index % 3}" })
}

# Firewall module with count
module "firewall" {
  count       = var.create_vpc ? 15 : 0
  source      = "./modules/firewall"
  name_prefix = "${local.name_prefix}-fw-${count.index}"
  vpc_id      = local.vpc_id
  subnet_ids  = local.subnet_ids
  tags        = local.common_tags
}

# Local path with subdir (source = ./modules/stack//vpc)
module "stack_vpc" {
  source = "./modules/stack//vpc"
}

# Module output consumed by root (reference)
resource "aws_instance" "from_module_output" {
  count         = var.create_vpc ? 1 : 0
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "${local.name_prefix}-from-module"
  }
}
