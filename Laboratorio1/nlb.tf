module "nlb" {
  source = "git::https://github.com/Cam1loGsz/PruebasAWS.git//modules/NLB?ref=main"

  name   = "nlb-test"
  vpc_id = local.vpc_id

  subnets = local.subnet_ids

  internal = false

  security_group_id = [module.security_group["nlb_tests_sg"].security_group_id]

  enable_cross_zone_load_balancing = true

  #################
  # TARGET GROUP
  #################
  target_groups = {
    tg-tcp-80 = {
      name        = "tg-tcp-80"
      port        = 80
      protocol    = "TCP"
      target_type = "instance"

      health_check = {
        enabled             = true
        protocol            = "TCP"
        port                = "traffic-port"
        interval            = 30
        timeout             = 10
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }

      targets = [
        {
          id   = "i-0123456789abcdef0"
          port = 80
        },
        {
          id   = "i-0fedcba9876543210"
          port = 80
        }
      ]
    }
  }

  ################
  # LISTENER 80
  ################
  listeners = [
    {
      port     = 80
      protocol = "TCP"
      default_target_group = "tg-tcp-80"
    }
  ]
}
