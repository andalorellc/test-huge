# Network firewall: policy + firewall, one subnet_mapping, multiple, conditional for_each

resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${local.name_prefix}-fw-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }

  tags = local.common_tags
}

# Single - one subnet_mapping
resource "aws_networkfirewall_firewall" "main" {
  count               = var.create_vpc ? 1 : 0
  name                = "${local.name_prefix}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = local.vpc_id

  subnet_mapping {
    subnet_id = length(local.subnet_ids) > 0 ? local.subnet_ids[0] : null
  }

  tags = local.common_tags
}

# count

locals {
  _ta_exclude_scaled = var.environment == "dev" && var.service == "test-huge"
}

resource "aws_networkfirewall_firewall" "scaled" {
  count = local._ta_exclude_scaled ? 0 : 1

  count               = var.create_vpc ? var.firewall_count : 0
  name                = "${local.name_prefix}-fw-${count.index}"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = local.vpc_id

  subnet_mapping {
    subnet_id = local.subnet_ids[count.index % length(local.subnet_ids)]
  }

  tags = {
    Name = format("%s-fw-%02d", local.name_prefix, count.index)
  }
}

# Conditional for_each
resource "aws_networkfirewall_firewall" "conditional_each" {
  for_each            = var.create_vpc ? local.fw_config : {}
  name                = "${local.name_prefix}-${each.key}"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = local.vpc_id

  subnet_mapping {
    subnet_id = length(local.subnet_ids) > 0 ? local.subnet_ids[0] : null
  }

  tags = {
    Name = each.key
  }
}
