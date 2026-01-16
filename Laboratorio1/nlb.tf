# module "nlb" {
#   source = "git::https://github.com/Cam1loGsz/PruebasAWS.git//modules/NLB?ref=main"

#   name   = "nlb-test"
#   vpc_id = local.vpc_id

#   subnets = local.subnet_ids

#   internal = false

#   security_group_id = [module.security_group["nlb_tests_sg"].security_group_id]

#   enable_cross_zone_load_balancing = true

#   #################
#   # TARGET GROUP
#   #################
#   target_groups = {
#     tg-tcp-80 = {
#       name        = "tg-tcp-80"
#       port        = 80
#       protocol    = "TCP"
#       target_type = "instance"

#       health_check = {
#         enabled             = true
#         protocol            = "TCP"
#         port                = "traffic-port"
#         interval            = 30
#         timeout             = 10
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#       }

#       targets = [
#         {
#           target_id   = "i-0b30c54787f2db922"
#           port = 80
#         },
#         {
#           target_id   = "i-019f4b14842ee3181"
#           port = 80
#         }
#       ]
#     }
#   }

#   ################
#   # LISTENER 80
#   ################
#   listeners = {
#     listener_80 = {
#       port               = 80
#       protocol           = "TCP"
#       target_group_key   = "tg-tcp-80"
#     }
#   }
# }
