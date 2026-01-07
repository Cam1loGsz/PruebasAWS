module "security_group" {
  source   = "git::https://github.com/Cam1loGsz/PruebasAWS.git//modules/SG?ref=main"
  for_each = local.security_groups

  vpc_id        = each.value.vpc_id
  name          = each.value.name
  description   = each.value.description
  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules
}
