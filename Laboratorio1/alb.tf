module "alb" {
  source = "git::https://github.com/Cam1loGsz/PruebasAWS.git//modules/ALB?ref=main"

  name   = "alb-simple"
  vpc_id = local.vpc_id

  subnets = local.subnet_ids

  internal              = false
  create_security_group = false
  additional_security_group_ids     = [module.security_group["alb_tests_sg"].security_group_id]
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

  ################
  # LISTENER 80
  ################
  listeners = [
    {
      port     = 80
      protocol = "HTTP"
      default_target_group = "tg-http"
        
    }
  ]
  
}

resource "aws_lb_target_group_attachment" "ec2_1" {
  target_group_arn = module.alb.target_group_arns["tg-http"]
  target_id        = module.ec2_instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_2" {
  target_group_arn = module.alb.target_group_arns["tg-http"]
  target_id        = module.ec2_instance_2.id
  port             = 80
}
