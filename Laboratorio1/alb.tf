module "alb" {
  source = "git::https://github.com/Cam1loGsz/PruebasAWS.git//modules/ALB?ref=main"

  name   = "alb-simple"
  vpc_id = locals.vpc_id

  subnets = locals.subnet_ids

  internal              = false
  create_security_group = false
  security_groups       = [module.security_group["alb_tests_sg"].security_group_id]
  enable_cross_zone_load_balancing = true

  #################
  # TARGET GROUP
  #################
    

  target_groups = {
    tg-http = {
      name        = "tg-http"
      port        = 80
      protocol    = "HTTP"
      target_type = "instance"

      health_check = {
        enabled             = true
        path                = "/"
        protocol            = "HTTP"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  #################
  # LISTENER 80
  #################
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      target_group_key = "tg-http"
        
    }
  }

  
}
