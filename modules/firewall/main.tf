resource "aws_networkfirewall_firewall_policy" "policy" {
  name = "${var.name_prefix}-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }
  tags = var.tags
}

resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.name_prefix}-fw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.policy.arn
  vpc_id              = var.vpc_id
  subnet_mapping { subnet_id = var.subnet_ids[0] }
  tags = var.tags
}
