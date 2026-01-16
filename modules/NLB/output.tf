output "nlb_id" {
  description = "ID del Network Load Balancer"
  value       = aws_lb.this.id
}

output "nlb_arn" {
  description = "ARN del Network Load Balancer"
  value       = aws_lb.this.arn
}

output "nlb_arn_suffix" {
  description = "ARN suffix del Network Load Balancer para métricas de CloudWatch"
  value       = aws_lb.this.arn_suffix
}

output "nlb_dns_name" {
  description = "Nombre DNS del Network Load Balancer"
  value       = aws_lb.this.dns_name
}

output "nlb_zone_id" {
  description = "Zone ID canónico del Network Load Balancer"
  value       = aws_lb.this.zone_id
}

output "target_group_arns" {
  description = "Mapa de ARNs de los Target Groups creados"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}

output "target_group_ids" {
  description = "Mapa de IDs de los Target Groups creados"
  value       = { for k, v in aws_lb_target_group.this : k => v.id }
}

output "target_group_arn_suffixes" {
  description = "Mapa de ARN suffixes de los Target Groups para métricas de CloudWatch"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn_suffix }
}

output "target_group_names" {
  description = "Mapa de nombres de los Target Groups creados"
  value       = { for k, v in aws_lb_target_group.this : k => v.name }
}

output "listener_arns" {
  description = "Mapa de ARNs de los Listeners creados"
  value       = { for k, v in aws_lb_listener.this : k => v.arn }
}

output "listener_ids" {
  description = "Mapa de IDs de los Listeners creados"
  value       = { for k, v in aws_lb_listener.this : k => v.id }
}