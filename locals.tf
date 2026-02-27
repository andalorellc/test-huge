# Locals used across resources (shared and isolated patterns)

locals {
  # Shared
  env_short     = substr(var.environment, 0, 3)
  name_prefix   = "${var.service}-${var.environment}"
  common_tags   = { Environment = var.environment, Service = var.service }
  azs_set       = toset(var.azs)
  endpoint_map  = { for i, s in var.endpoint_services : s => { index = i } }

  # Isolated local (only used by one resource - Case 2)
  ebs_size_isolated = 50
  eip_domain        = "vpc"

  # Conditional for_each
  fw_config = var.create_firewalls ? { for i in range(local.fw_count) : "fw-${i}" => { tier = "tier-${i % 2}" } } : {}
  fw_count  = var.firewall_count

  # Map for for_each modules
  env_config = {
    dev   = { instance_type = "t3.small", replicas = 2 }
    stage = { instance_type = "t3.medium", replicas = 3 }
    prod  = { instance_type = "t3.large", replicas = 5 }
  }
}
