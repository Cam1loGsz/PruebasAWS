terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Network Load Balancer
resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.subnets
  ip_address_type    = var.ip_address_type

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  # Security Group solo se aplica si se proporciona
  security_groups = var.security_group_id != null ? var.security_group_id : null

  # Configuración de logs de acceso
  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      enabled = true
      prefix  = var.access_logs_prefix
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Target Groups
resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name                 = "${var.name}-${each.key}"
  port                 = each.value.port
  protocol             = each.value.protocol
  vpc_id               = var.vpc_id
  target_type          = each.value.target_type
  deregistration_delay = each.value.deregistration_delay

  # Health Check
  health_check {
    enabled             = lookup(each.value.health_check, "enabled", true)
    interval            = lookup(each.value.health_check, "interval", 30)
    port                = lookup(each.value.health_check, "port", "traffic-port")
    protocol            = lookup(each.value.health_check, "protocol", "TCP")
    healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 3)
    timeout             = lookup(each.value.health_check, "timeout", 10)
  }

  # Stickiness (opcional)
  dynamic "stickiness" {
    for_each = each.value.stickiness != null ? [each.value.stickiness] : []
    content {
      enabled = stickiness.value.enabled
      type    = stickiness.value.type
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${each.key}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "this" {
  for_each = merge([
    for tg_key, tg_config in var.target_groups : {
      for idx, target in tg_config.targets : "${tg_key}-${idx}" => {
        target_group_arn  = aws_lb_target_group.this[tg_key].arn
        target_id         = target.target_id
        port              = target.port
        availability_zone = target.availability_zone
      }
    }
  ]...)

  target_group_arn  = each.value.target_group_arn
  target_id         = each.value.target_id
  port              = each.value.port
  availability_zone = each.value.availability_zone != "all" ? each.value.availability_zone : null
}

# Listeners
resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = each.value.certificate_arn
  alpn_policy       = each.value.alpn_policy
  ssl_policy        = each.value.protocol == "TLS" ? each.value.ssl_policy : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-listener-${each.key}"
    }
  )
}

# Data source para obtener información de la zona de disponibilidad
data "aws_subnet" "selected" {
  count = length(var.subnets)
  id    = var.subnets[count.index]
}