variable "name" {
  description = "Nombre del Network Load Balancer"
  type        = string
}

variable "internal" {
  description = "Si el NLB debe ser interno (true) o público (false)"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Lista de IDs de subnets donde se desplegará el NLB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Habilitar protección contra eliminación"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Habilitar balanceo de carga entre zonas de disponibilidad"
  type        = bool
  default     = true
}

variable "security_group_id" {
  description = "ID del Security Group a asociar al NLB (opcional)"
  type        = string
  default     = null
}

variable "enable_access_logs" {
  description = "Habilitar logs de acceso en S3"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "Nombre del bucket S3 para almacenar logs de acceso"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "Prefijo para los logs en el bucket S3"
  type        = string
  default     = ""
}

variable "ip_address_type" {
  description = "Tipo de dirección IP (ipv4 o dualstack)"
  type        = string
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type debe ser 'ipv4' o 'dualstack'"
  }
}

variable "target_groups" {
  description = "Mapa de Target Groups a crear con sus configuraciones"
  type = map(object({
    port                 = number
    protocol             = string
    target_type          = optional(string, "instance")
    deregistration_delay = optional(number, 300)
    
    health_check = optional(object({
      enabled             = optional(bool, true)
      interval            = optional(number, 30)
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "TCP")
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      timeout             = optional(number, 10)
    }), {})
    
    stickiness = optional(object({
      enabled = optional(bool, false)
      type    = optional(string, "source_ip")
    }), null)
    
    targets = optional(list(object({
      target_id         = string
      port              = optional(number)
      availability_zone = optional(string, "all")
    })), [])
  }))
  default = {}
}

variable "listeners" {
  description = "Mapa de listeners a crear"
  type = map(object({
    port               = number
    protocol           = string
    certificate_arn    = optional(string)
    alpn_policy        = optional(string)
    ssl_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    target_group_key   = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags a aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los Target Groups"
  type        = string
}