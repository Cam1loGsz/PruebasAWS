# outputs.tf

# ==========================================
# Security Group Outputs
# ==========================================

output "security_group_id" {
  description = "ID del security group creado (null si create_security_group = false)"
  value       = var.create_security_group ? aws_security_group.alb[0].id : null
}

output "security_group_arn" {
  description = "ARN del security group creado (null si create_security_group = false)"
  value       = var.create_security_group ? aws_security_group.alb[0].arn : null
}

output "security_group_name" {
  description = "Nombre del security group creado (null si create_security_group = false)"
  value       = var.create_security_group ? aws_security_group.alb[0].name : null
}

output "all_security_group_ids" {
  description = "Lista de todos los security group IDs asociados al ALB"
  value       = var.create_security_group ? concat([aws_security_group.alb[0].id], var.additional_security_group_ids) : var.security_group_ids
}

# ==========================================
# ALB Outputs
# ==========================================

output "alb_id" {
  description = "ID del Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN del Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix del ALB para usar con CloudWatch metrics"
  value       = aws_lb.main.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name del Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID del ALB (para Route53 alias records)"
  value       = aws_lb.main.zone_id
}

# ==========================================
# Listener Outputs
# ==========================================

output "http_listener_arn" {
  description = "ARN del listener HTTP"
  value       = var.enable_http_listener ? aws_lb_listener.http[0].arn : null
}

output "https_listener_arn" {
  description = "ARN del listener HTTPS"
  value       = var.enable_https_listener ? aws_lb_listener.https[0].arn : null
}

# ==========================================
# Target Group Outputs
# ==========================================

output "target_group_arns" {
  description = "Mapa de ARNs de los target groups (key = target_group_key)"
  value = {
    for key, tg in aws_lb_target_group.main : key => tg.arn
  }
}

output "target_group_arn_suffixes" {
  description = "Mapa de ARN suffixes de los target groups para CloudWatch metrics"
  value = {
    for key, tg in aws_lb_target_group.main : key => tg.arn_suffix
  }
}

output "target_group_ids" {
  description = "Mapa de IDs de los target groups"
  value = {
    for key, tg in aws_lb_target_group.main : key => tg.id
  }
}

output "target_group_names" {
  description = "Mapa de nombres de los target groups"
  value = {
    for key, tg in aws_lb_target_group.main : key => tg.name
  }
}

# ==========================================
# Listener Rules Outputs
# ==========================================

output "forward_rules" {
  description = "Mapa de reglas de tipo forward con sus ARNs e IDs"
  value = {
    for key, rule in aws_lb_listener_rule.forward : key => {
      arn      = rule.arn
      id       = rule.id
      priority = rule.priority
    }
  }
}

output "redirect_rules" {
  description = "Mapa de reglas de tipo redirect con sus ARNs e IDs"
  value = {
    for key, rule in aws_lb_listener_rule.redirect : key => {
      arn      = rule.arn
      id       = rule.id
      priority = rule.priority
    }
  }
}

# ==========================================
# Complete Info Output
# ==========================================

output "alb_complete_info" {
  description = "Información completa del ALB y sus componentes"
  value = {
    alb = {
      id         = aws_lb.main.id
      arn        = aws_lb.main.arn
      dns_name   = aws_lb.main.dns_name
      zone_id    = aws_lb.main.zone_id
      arn_suffix = aws_lb.main.arn_suffix
    }
    listeners = {
      http  = var.enable_http_listener ? aws_lb_listener.http[0].arn : null
      https = var.enable_https_listener ? aws_lb_listener.https[0].arn : null
    }
    target_groups = {
      for key, tg in aws_lb_target_group.main : key => {
        arn        = tg.arn
        arn_suffix = tg.arn_suffix
        name       = tg.name
        port       = tg.port
        protocol   = tg.protocol
      }
    }
  }
}