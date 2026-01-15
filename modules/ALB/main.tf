# main.tf

# Security Group para el ALB (opcional)
resource "aws_security_group" "alb" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-alb-"
  description = "Security group for ${var.name} Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Reglas de Ingress del Security Group
resource "aws_vpc_security_group_ingress_rule" "alb" {
  for_each = var.create_security_group ? var.security_group_ingress_rules : {}

  security_group_id = aws_security_group.alb[0].id
  description       = each.value.description

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol

  # CIDR blocks
  cidr_ipv4 = lookup(each.value, "cidr_ipv4", null)
  cidr_ipv6 = lookup(each.value, "cidr_ipv6", null)

  # Prefix list
  prefix_list_id = lookup(each.value, "prefix_list_id", null)

  # Security group source
  referenced_security_group_id = lookup(each.value, "source_security_group_id", null)

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {})
  )
}

# Reglas de Egress del Security Group
resource "aws_vpc_security_group_egress_rule" "alb" {
  for_each = var.create_security_group ? var.security_group_egress_rules : {}

  security_group_id = aws_security_group.alb[0].id
  description       = each.value.description

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol

  # CIDR blocks
  cidr_ipv4 = lookup(each.value, "cidr_ipv4", null)
  cidr_ipv6 = lookup(each.value, "cidr_ipv6", null)

  # Prefix list
  prefix_list_id = lookup(each.value, "prefix_list_id", null)

  # Security group destination
  referenced_security_group_id = lookup(each.value, "destination_security_group_id", null)

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {})
  )
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.create_security_group ? concat([aws_security_group.alb[0].id], var.additional_security_group_ids) : var.security_group_ids
  subnets            = var.subnets

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open             = var.enable_waf_fail_open
  idle_timeout                     = var.idle_timeout
  ip_address_type                  = var.ip_address_type

  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
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
resource "aws_lb_target_group" "main" {
  for_each = var.target_groups

  name                 = each.value.name
  port                 = each.value.port
  protocol             = each.value.protocol
  vpc_id               = var.vpc_id
  target_type          = lookup(each.value, "target_type", "instance")
  deregistration_delay = lookup(each.value, "deregistration_delay", 300)

  health_check {
    enabled             = lookup(each.value.health_check, "enabled", true)
    interval            = lookup(each.value.health_check, "interval", 30)
    path                = lookup(each.value.health_check, "path", "/")
    port                = lookup(each.value.health_check, "port", "traffic-port")
    protocol            = lookup(each.value.health_check, "protocol", each.value.protocol)
    timeout             = lookup(each.value.health_check, "timeout", 5)
    healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 3)
    matcher             = lookup(each.value.health_check, "matcher", "200")
  }

  dynamic "stickiness" {
    for_each = lookup(each.value, "stickiness", null) != null ? [each.value.stickiness] : []
    content {
      type            = stickiness.value.type
      cookie_duration = lookup(stickiness.value, "cookie_duration", 86400)
      enabled         = lookup(stickiness.value, "enabled", true)
    }
  }

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {}),
    {
      Name = each.value.name
    }
  )
}

# Listeners dinámicos
resource "aws_lb_listener" "main" {
  for_each = { for idx, listener in var.listeners : idx => listener }

  load_balancer_arn = aws_lb.main.arn
  port              = each.value.port
  protocol          = each.value.protocol

  # SSL/TLS configuration (solo si el protocolo es HTTPS)
  ssl_policy      = each.value.protocol == "HTTPS" ? lookup(each.value, "ssl_policy", "ELBSecurityPolicy-TLS13-1-2-2021-06") : null
  certificate_arn = each.value.protocol == "HTTPS" ? lookup(each.value, "certificate_arn", null) : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.value.default_target_group_key].arn
  }

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {})
  )
}

# Listener Rules - FORWARD
resource "aws_lb_listener_rule" "forward" {
  for_each = {
    for rule_key, rule in var.listener_rules : rule_key => rule
    if rule.type == "forward"
  }

  listener_arn = aws_lb_listener.main[each.value.listener_index].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.value.target_group_key].arn
  }

  # Path Pattern Condition
  dynamic "condition" {
    for_each = lookup(each.value, "path_pattern", null) != null ? [1] : []
    content {
      path_pattern {
        values = each.value.path_pattern
      }
    }
  }

  # Host Header Condition
  dynamic "condition" {
    for_each = lookup(each.value, "host_header", null) != null ? [1] : []
    content {
      host_header {
        values = each.value.host_header
      }
    }
  }

  # HTTP Header Condition
  dynamic "condition" {
    for_each = lookup(each.value, "http_header", null) != null ? [1] : []
    content {
      http_header {
        http_header_name = each.value.http_header.name
        values           = each.value.http_header.values
      }
    }
  }

  # HTTP Request Method Condition
  dynamic "condition" {
    for_each = lookup(each.value, "http_request_method", null) != null ? [1] : []
    content {
      http_request_method {
        values = each.value.http_request_method
      }
    }
  }

  # Query String Condition
  dynamic "condition" {
    for_each = lookup(each.value, "query_string", null) != null ? each.value.query_string : []
    content {
      query_string {
        key   = lookup(condition.value, "key", null)
        value = condition.value.value
      }
    }
  }

  # Source IP Condition
  dynamic "condition" {
    for_each = lookup(each.value, "source_ip", null) != null ? [1] : []
    content {
      source_ip {
        values = each.value.source_ip
      }
    }
  }

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {})
  )
}

# Listener Rules - REDIRECT
resource "aws_lb_listener_rule" "redirect" {
  for_each = {
    for rule_key, rule in var.listener_rules : rule_key => rule
    if rule.type == "redirect"
  }

  listener_arn = aws_lb_listener.main[each.value.listener_index].arn
  priority     = each.value.priority

  action {
    type = "redirect"

    redirect {
      protocol    = lookup(each.value.redirect, "protocol", "#{protocol}")
      port        = lookup(each.value.redirect, "port", "#{port}")
      host        = lookup(each.value.redirect, "host", "#{host}")
      path        = lookup(each.value.redirect, "path", "/#{path}")
      query       = lookup(each.value.redirect, "query", "#{query}")
      status_code = lookup(each.value.redirect, "status_code", "HTTP_301")
    }
  }

  # Path Pattern Condition
  dynamic "condition" {
    for_each = lookup(each.value, "path_pattern", null) != null ? [1] : []
    content {
      path_pattern {
        values = each.value.path_pattern
      }
    }
  }

  # Host Header Condition
  dynamic "condition" {
    for_each = lookup(each.value, "host_header", null) != null ? [1] : []
    content {
      host_header {
        values = each.value.host_header
      }
    }
  }

  # HTTP Header Condition
  dynamic "condition" {
    for_each = lookup(each.value, "http_header", null) != null ? [1] : []
    content {
      http_header {
        http_header_name = each.value.http_header.name
        values           = each.value.http_header.values
      }
    }
  }

  # Query String Condition
  dynamic "condition" {
    for_each = lookup(each.value, "query_string", null) != null ? each.value.query_string : []
    content {
      query_string {
        key   = lookup(condition.value, "key", null)
        value = condition.value.value
      }
    }
  }

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {})
  )
}

# Additional SSL/TLS Certificates
resource "aws_lb_listener_certificate" "additional" {
  for_each = var.additional_certificates

  listener_arn    = aws_lb_listener.main[each.value.listener_index].arn
  certificate_arn = each.value.certificate_arn
}