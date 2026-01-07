
resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  # Dynamic block para ingress
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port                = ingress.value.from_port
      to_port                  = ingress.value.to_port
      protocol                 = ingress.value.protocol
      cidr_blocks              = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks         = lookup(ingress.value, "ipv6_cidr_blocks", null)
      security_groups          = lookup(ingress.value, "security_groups", null)
      self                     = lookup(ingress.value, "self", null)
      prefix_list_ids          = lookup(ingress.value, "prefix_list_ids", null)
      description              = lookup(ingress.value, "description", null)
    }
  }

  # Dynamic block para egress
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port                = egress.value.from_port
      to_port                  = egress.value.to_port
      protocol                 = egress.value.protocol
      cidr_blocks              = lookup(egress.value, "cidr_blocks", null)
      ipv6_cidr_blocks         = lookup(egress.value, "ipv6_cidr_blocks", null)
      security_groups          = lookup(egress.value, "security_groups", null)
      self                     = lookup(egress.value, "self", null)
      prefix_list_ids          = lookup(egress.value, "prefix_list_ids", null)
      description              = lookup(egress.value, "description", null)
    }
  }
}