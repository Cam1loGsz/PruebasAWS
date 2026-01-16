# variables.tf

# ==========================================
# Security Group Configuration
# ==========================================

variable "create_security_group" {
  description = "Si es true, crea un security group nuevo para el ALB. Si es false, usa los IDs proporcionados en security_group_ids"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Lista de security group IDs existentes para el ALB (requerido si create_security_group = false)"
  type        = list(string)
  default     = []
}

variable "additional_security_group_ids" {
  description = "Lista de security group IDs adicionales para agregar cuando create_security_group = true"
  type        = list(string)
  default     = []
}

variable "security_group_ingress_rules" {
  description = <<-EOT
    Mapa de reglas de ingress para el security group creado (solo aplica si create_security_group = true).
    Cada regla debe tener:
    - description: Descripción de la regla
    - from_port: Puerto inicial
    - to_port: Puerto final
    - ip_protocol: Protocolo (tcp, udp, icmp, o -1 para todos)
    - cidr_ipv4: (Opcional) CIDR IPv4 de origen
    - cidr_ipv6: (Opcional) CIDR IPv6 de origen
    - prefix_list_id: (Opcional) ID de prefix list
    - source_security_group_id: (Opcional) ID del security group de origen
    - tags: (Opcional) Tags adicionales
  EOT
  type = map(object({
    description                = string
    from_port                  = number
    to_port                    = number
    ip_protocol                = string
    cidr_ipv4                  = optional(string)
    cidr_ipv6                  = optional(string)
    prefix_list_id             = optional(string)
    source_security_group_id   = optional(string)
    tags                       = optional(map(string))
  }))
  default = {
    http = {
      description = "Allow HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

variable "security_group_egress_rules" {
  description = <<-EOT
    Mapa de reglas de egress para el security group creado (solo aplica si create_security_group = true).
    Cada regla debe tener:
    - description: Descripción de la regla
    - from_port: Puerto inicial
    - to_port: Puerto final
    - ip_protocol: Protocolo (tcp, udp, icmp, o -1 para todos)
    - cidr_ipv4: (Opcional) CIDR IPv4 de destino
    - cidr_ipv6: (Opcional) CIDR IPv6 de destino
    - prefix_list_id: (Opcional) ID de prefix list
    - destination_security_group_id: (Opcional) ID del security group de destino
    - tags: (Opcional) Tags adicionales
  EOT
  type = map(object({
    description                    = string
    from_port                      = number
    to_port                        = number
    ip_protocol                    = string
    cidr_ipv4                      = optional(string)
    cidr_ipv6                      = optional(string)
    prefix_list_id                 = optional(string)
    destination_security_group_id  = optional(string)
    tags                           = optional(map(string))
  }))
  default = {
    all_traffic = {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

# ==========================================
# ALB Configuration
# ==========================================

variable "name" {
  description = "Nombre del Application Load Balancer"
  type        = string
}

variable "internal" {
  description = "Si el ALB es interno (true) o público (false)"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Lista de subnet IDs donde se desplegará el ALB (mínimo 2 subnets en diferentes AZs)"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID donde se crearán los target groups y security group (si aplica)"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Habilitar protección contra eliminación del ALB"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Habilitar balanceo de carga cross-zone"
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Habilitar HTTP/2"
  type        = bool
  default     = true
}

variable "enable_waf_fail_open" {
  description = "Permitir tráfico si WAF falla"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Tiempo en segundos de idle antes de cerrar conexión"
  type        = number
  default     = 60
}

variable "ip_address_type" {
  description = "Tipo de dirección IP (ipv4 o dualstack)"
  type        = string
  default     = "ipv4"
}

# ==========================================
# Access Logs
# ==========================================

variable "access_logs_enabled" {
  description = "Habilitar logs de acceso"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "Nombre del bucket S3 para logs de acceso"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "Prefijo para los logs en el bucket S3"
  type        = string
  default     = ""
}

# ==========================================
# Listeners Configuration
# ==========================================

variable "listeners" {
  description = <<-EOT
    Lista de listeners para el ALB. Cada listener debe tener:
    - port: Puerto del listener (80, 443, etc.)
    - protocol: Protocolo (HTTP o HTTPS)
    - default_target_group: Key del target group por defecto
    - ssl_policy: (Opcional) Política SSL solo para HTTPS - default: ELBSecurityPolicy-TLS13-1-2-2021-06
    - certificate_arn: (Opcional) ARN del certificado SSL/TLS, requerido para HTTPS
    - tags: (Opcional) Tags adicionales para el listener
  EOT
  type = list(object({
    port                     = number
    protocol                 = string
    default_target_group     = string
    ssl_policy               = optional(string)
    certificate_arn          = optional(string)
    tags                     = optional(map(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for listener in var.listeners :
      contains(["HTTP", "HTTPS"], listener.protocol)
    ])
    error_message = "El protocolo debe ser HTTP o HTTPS."
  }

  validation {
    condition = alltrue([
      for listener in var.listeners :
      listener.protocol == "HTTPS" ? listener.certificate_arn != null : true
    ])
    error_message = "certificate_arn es requerido cuando el protocolo es HTTPS."
  }
}

variable "additional_certificates" {
  description = <<-EOT
    Mapa de certificados SSL/TLS adicionales para agregar a listeners HTTPS.
    Cada entrada debe tener:
    - listener_index: Índice del listener al que agregar el certificado (0, 1, 2, etc.)
    - certificate_arn: ARN del certificado adicional
  EOT
  type = map(object({
    listener_index  = number
    certificate_arn = string
  }))
  default = {}
}

# ==========================================
# Target Groups
# ==========================================

variable "target_groups" {
  description = <<-EOT
    Mapa de target groups. Cada target group debe tener:
    - name: Nombre del target group
    - port: Puerto del target group
    - protocol: Protocolo (HTTP, HTTPS)
    - target_type: Tipo de target (instance, ip, lambda) - default: instance
    - deregistration_delay: Tiempo de espera antes de deregistrar - default: 300
    - health_check: Configuración del health check
      - enabled: Habilitar health check - default: true
      - interval: Intervalo entre checks - default: 30
      - path: Path para el health check - default: /
      - port: Puerto para el health check - default: traffic-port
      - protocol: Protocolo del health check - default: mismo que target group
      - timeout: Timeout del health check - default: 5
      - healthy_threshold: Número de checks exitosos - default: 3
      - unhealthy_threshold: Número de checks fallidos - default: 3
      - matcher: Códigos HTTP de éxito - default: 200
    - stickiness: (Opcional) Configuración de sesiones pegajosas
      - type: Tipo de stickiness (lb_cookie, app_cookie)
      - cookie_duration: Duración de la cookie en segundos - default: 86400
      - enabled: Habilitar stickiness - default: true
    - tags: (Opcional) Tags adicionales
  EOT
  type = map(object({
    name                 = string
    port                 = number
    protocol             = string
    target_type          = optional(string)
    deregistration_delay = optional(number)
    health_check = object({
      enabled             = optional(bool)
      interval            = optional(number)
      path                = optional(string)
      port                = optional(string)
      protocol            = optional(string)
      timeout             = optional(number)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
      matcher             = optional(string)
    })
    stickiness = optional(object({
      type            = string
      cookie_duration = optional(number)
      enabled         = optional(bool)
    }))
    tags = optional(map(string))
  }))
}

variable "default_target_group" {
  description = "(DEPRECATED) Este campo ya no se usa. Define default_target_group en cada listener"
  type        = string
  default     = ""
}

# ==========================================
# Listener Rules
# ==========================================

variable "listener_rules" {
  description = <<-EOT
    Mapa de reglas para los listeners. Cada regla debe tener:
    
    Campos obligatorios:
    - type: Tipo de acción ("forward" o "redirect")
    - listener_index: Índice del listener al que se aplica (0, 1, 2, etc.)
    - priority: Prioridad de la regla (1-50000, menor número = mayor prioridad)
    
    Para tipo "forward":
    - target_group_key: Key del target group al que enviar el tráfico
    
    Para tipo "redirect":
    - redirect: Objeto con configuración de redirección
      - protocol: Protocolo de destino - default: #{protocol} (mantiene el original)
      - port: Puerto de destino - default: #{port} (mantiene el original)
      - host: Host de destino - default: #{host} (mantiene el original)
      - path: Path de destino - default: /#{path} (mantiene el original)
      - query: Query string - default: #{query} (mantiene el original)
      - status_code: Código HTTP de redirección (HTTP_301 o HTTP_302) - default: HTTP_301
    
    Condiciones (al menos una es requerida):
    - path_pattern: Lista de patrones de path (ej: ["/api/*", "/v1/*"])
    - host_header: Lista de hosts (ej: ["example.com", "*.example.com"])
    - http_header: Header HTTP específico
      - name: Nombre del header
      - values: Lista de valores del header
    - http_request_method: Lista de métodos HTTP (ej: ["GET", "POST"])
    - query_string: Lista de query strings
      - key: (Opcional) Nombre del parámetro
      - value: Valor del parámetro
    - source_ip: Lista de rangos CIDR (ej: ["192.168.1.0/24"])
    
    - tags: (Opcional) Tags adicionales para la regla
  EOT
  type = map(object({
    type             = string
    listener_index   = number
    priority         = number
    target_group_key = optional(string)
    redirect = optional(object({
      protocol    = optional(string)
      port        = optional(string)
      host        = optional(string)
      path        = optional(string)
      query       = optional(string)
      status_code = optional(string)
    }))
    path_pattern        = optional(list(string))
    host_header         = optional(list(string))
    http_header = optional(object({
      name   = string
      values = list(string)
    }))
    http_request_method = optional(list(string))
    query_string = optional(list(object({
      key   = optional(string)
      value = string
    })))
    source_ip = optional(list(string))
    tags      = optional(map(string))
  }))
  default = {}
}

# ==========================================
# Tags
# ==========================================

variable "tags" {
  description = "Tags para aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}