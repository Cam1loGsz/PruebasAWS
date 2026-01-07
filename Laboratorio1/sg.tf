module "security_group" {
  source   = "git::https://github.com/Cam1loGsz/PruebasAWS.git//modules/SG?ref=main"
  for_each = local.security_groups

  vpc_id        = lookup(local.security_groups, each.key, {})["vpc_id"]
  name          = lookup(local.security_groups, each.key, {})["name"]
  description   = lookup(local.security_groups, each.key, {})["description"]
  ingress_rules = lookup(local.security_groups, each.key, {})["ingress_rules"]
  egress_rules  = lookup(local.security_groups, each.key, {})["egress_rules"]
}
