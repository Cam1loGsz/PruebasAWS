resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.this.id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  self                     = lookup(each.value, "self", null)
  prefix_list_ids           = lookup(each.value, "prefix_list_ids", null)
  description              = lookup(each.value, "description", null)


}
resource "aws_security_group_rule" "egress" {
  type                     = "egress"
  security_group_id        = aws_security_group.this.id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  self                     = lookup(each.value, "self", null)
  prefix_list_ids           = lookup(each.value, "prefix_list_ids", null)
  description              = lookup(each.value, "description", null)

}
