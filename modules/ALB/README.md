# AWS Application Load Balancer (ALB) Terraform Module

Módulo completo y flexible de Terraform para crear y gestionar un Application Load Balancer en AWS con soporte para múltiples target groups, listener rules con acciones de tipo `forward` y `redirect`, y configuración avanzada de condiciones. Incluye la opción de crear un security group automáticamente o usar security groups existentes.

## 📋 Características

- ✅ Configuración completa de ALB (interno o público)
- ✅ **Security Group flexible**: Crea uno nuevo o usa SGs existentes
- ✅ Soporte para listeners HTTP y HTTPS
- ✅ Múltiples target groups con health checks personalizables
- ✅ Listener rules con acciones **forward** y **redirect**
- ✅ Condiciones flexibles (path, host, headers, query strings, source IP, etc.)
- ✅ Redirección automática de HTTP a HTTPS (opcional)
- ✅ Certificados SSL/TLS adicionales
- ✅ Sesiones pegajosas (sticky sessions)
- ✅ Access logs a S3 (opcional)
- ✅ Outputs completos para integración

## 🔐 Security Groups - Dos Opciones

### Opción 1: Crear Security Group Automáticamente (Recomendado)

El módulo puede crear y configurar automáticamente un security group para tu ALB:

```hcl
module "alb" {
  source = "./modules/alb"

  name   = "my-alb"
  vpc_id = "vpc-12345678"
  
  # Crear security group automáticamente
  create_security_group = true
  
  # Reglas de ingress personalizadas
  security_group_ingress_rules = {
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
  
  # Reglas de egress personalizadas
  security_group_egress_rules = {
    to_targets = {
      description                = "Allow traffic to target instances"
      from_port                  = 0
      to_port                    = 65535
      ip_protocol                = "tcp"
      destination_security_group_id = "sg-targets-xxx"
    }
  }
  
  # (Opcional) SGs adicionales al creado
  additional_security_group_ids = ["sg-additional-xxx"]
  
  # ... resto de configuración ...
}
```

### Opción 2: Usar Security Groups Existentes

Si ya tienes security groups creados, simplemente pasa sus IDs:

```hcl
module "alb" {
  source = "./modules/alb"

  name   = "my-alb"
  vpc_id = "vpc-12345678"
  
  # Usar security groups existentes
  create_security_group = false
  security_group_ids    = ["sg-existing1", "sg-existing2"]
  
  # ... resto de configuración ...
}
```

## 🚀 Uso Básico

### Ejemplo Simple con SG Automático

```hcl
module "alb" {
  source = "./modules/alb"

  name   = "my-application-alb"
  vpc_id = "vpc-12345678"
  
  # Security Group automático
  create_security_group = true
  
  subnets = ["subnet-abc123", "subnet-def456"]

  # Target Groups
  target_groups = {
    app = {
      name     = "app-tg"
      port     = 80
      protocol = "HTTP"
      health_check = {
        path                = "/health"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200"
      }
    }
  }

  default_target_group_key = "app"

  # Configuración HTTPS
  enable_https_listener = true
  certificate_arn       = "arn:aws:acm:us-east-1:123456789:certificate/xxx"

  }
}
```

## 🔐 Ejemplos de Security Groups

### Ejemplo 1: SG Básico con HTTP/HTTPS Público

```hcl
create_security_group = true

security_group_ingress_rules = {
  http = {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
  }
  https = {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
  }
}

security_group_egress_rules = {
  all = {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
  }
}
```

### Ejemplo 2: SG con Acceso Restringido (VPN/Oficina)

```hcl
create_security_group = true

security_group_ingress_rules = {
  https_vpn = {
    description = "Allow HTTPS from VPN"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv4   = "10.0.0.0/8"
  }
  https_office = {
    description = "Allow HTTPS from office"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv4   = "203.0.113.0/24"
  }
}
```

### Ejemplo 3: SG con Comunicación a Target Group Específico

```hcl
create_security_group = true

security_group_ingress_rules = {
  https = {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
  }
}

security_group_egress_rules = {
  to_app_servers = {
    description                   = "Allow to application servers"
    from_port                     = 8080
    to_port                       = 8080
    ip_protocol                   = "tcp"
    destination_security_group_id = "sg-app-servers-xxx"
  }
  to_database = {
    description                   = "Allow to database"
    from_port                     = 3306
    to_port                       = 3306
    ip_protocol                   = "tcp"
    destination_security_group_id = "sg-database-xxx"
  }
}
```

### Ejemplo 4: Usar SG Existente + Crear Uno Adicional

```hcl
# Crear un SG nuevo para reglas específicas
create_security_group = true

security_group_ingress_rules = {
  custom_port = {
    description = "Custom application port"
    from_port   = 8443
    to_port     = 8443
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
  }
}

# Y agregar SGs existentes
additional_security_group_ids = [
  "sg-standard-web-xxx",    # SG estándar de web
  "sg-monitoring-xxx"       # SG para monitoring
]
```

### Ejemplo 5: Solo Security Groups Existentes

```hcl
# No crear SG, usar solo existentes
create_security_group = false

security_group_ids = [
  "sg-web-public-xxx",
  "sg-internal-services-xxx"
]
```

## 🎯 Listener Rules - Forward

Las reglas de tipo `forward` envían el tráfico a un target group específico basándose en condiciones.

### Ejemplo 1: Forward por Path Pattern

```hcl
listener_rules = {
  api_rule = {
    type              = "forward"
    listener_protocol = "HTTPS"
    priority          = 100
    target_group_key  = "api"
    
    # Condición: Path comienza con /api/
    path_pattern = ["/api/*"]
  }
}
```

### Ejemplo 2: Forward por Host Header

```hcl
listener_rules = {
  subdomain_rule = {
    type              = "forward"
    listener_protocol = "HTTPS"
    priority          = 200
    target_group_key  = "app2"
    
    # Condición: Subdomain específico
    host_header = ["app.example.com"]
  }
}
```

### Ejemplo 3: Forward por HTTP Header

```hcl
listener_rules = {
  mobile_rule = {
    type              = "forward"
    listener_protocol = "HTTPS"
    priority          = 150
    target_group_key  = "mobile_app"
    
    # Condición: Header personalizado
    http_header = {
      name   = "User-Agent"
      values = ["*Mobile*", "*Android*", "*iPhone*"]
    }
  }
}
```

### Ejemplo 4: Forward por Query String

```hcl
listener_rules = {
  version_rule = {
    type              = "forward"
    listener_protocol = "HTTPS"
    priority          = 175
    target_group_key  = "v2_app"
    
    # Condición: Query string contiene version=2
    query_string = [
      {
        key   = "version"
        value = "2"
      }
    ]
  }
}
```

### Ejemplo 5: Forward por Método HTTP

```hcl
listener_rules = {
  post_rule = {
    type              = "forward"
    listener_protocol = "HTTPS"
    priority          = 125
    target_group_key  = "write_api"
    
    # Condición: Métodos POST, PUT, DELETE
    http_request_method = ["POST", "PUT", "DELETE"]
    path_pattern        = ["/api/*"]
  }
}
```

## 🔀 Listener Rules - Redirect

Las reglas de tipo `redirect` redirigen el tráfico a otra URL basándose en condiciones.

### Ejemplo 1: Redirect Simple (cambiar protocolo)

```hcl
listener_rules = {
  force_https = {
    type              = "redirect"
    listener_protocol = "HTTP"
    priority          = 1
    
    # Redirección: HTTP → HTTPS
    redirect = {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
    
    # Sin condición = aplica a todo el tráfico del listener
  }
}
```

### Ejemplo 2: Redirect con cambio de Host

```hcl
listener_rules = {
  old_domain_redirect = {
    type              = "redirect"
    listener_protocol = "HTTPS"
    priority          = 50
    
    # Redirección: old-domain.com → new-domain.com
    redirect = {
      host        = "new-domain.com"
      status_code = "HTTP_301"
    }
    
    host_header = ["old-domain.com"]
  }
}
```

### Ejemplo 3: Redirect con Path Rewrite

```hcl
listener_rules = {
  old_path_redirect = {
    type              = "redirect"
    listener_protocol = "HTTPS"
    priority          = 75
    
    # Redirección: /old-path/* → /new-path/*
    redirect = {
      path        = "/new-path/#{path}"
      status_code = "HTTP_301"
    }
    
    path_pattern = ["/old-path/*"]
  }
}
```

### Ejemplo 4: Redirect Completo (protocolo + host + path)

```hcl
listener_rules = {
  complete_redirect = {
    type              = "redirect"
    listener_protocol = "HTTP"
    priority          = 10
    
    # Redirección completa
    redirect = {
      protocol    = "HTTPS"
      port        = "443"
      host        = "www.example.com"
      path        = "/welcome/#{path}"
      query       = "ref=redirect&#{query}"
      status_code = "HTTP_302"
    }
    
    host_header = ["example.com"]
  }
}
```

### Ejemplo 5: Redirect Temporal (302) para Mantenimiento

```hcl
listener_rules = {
  maintenance_redirect = {
    type              = "redirect"
    listener_protocol = "HTTPS"
    priority          = 5
    
    # Redirección temporal a página de mantenimiento
    redirect = {
      path        = "/maintenance.html"
      status_code = "HTTP_302"  # Temporal
    }
    
    path_pattern = ["/admin/*", "/dashboard/*"]
  }
}
```

## 🎨 Placeholders en Redirect

Puedes usar placeholders para mantener partes de la URL original:

| Placeholder | Descripción | Ejemplo |
|------------|-------------|---------|
| `#{protocol}` | Protocolo original | http, https |
| `#{host}` | Host original | example.com |
| `#{port}` | Puerto original | 80, 443 |
| `#{path}` | Path original | /api/users |
| `#{query}` | Query string original | ?id=123 |

**Ejemplo:**
```hcl
redirect = {
  protocol = "HTTPS"           # Cambia a HTTPS
  host     = "#{host}"          # Mantiene host original
  path     = "/v2/#{path}"      # Agrega prefijo /v2/
  query    = "version=2&#{query}" # Agrega parámetro
}
```

## 📦 Ejemplo Completo con Múltiples Rules

```hcl
module "alb" {
  source = "./modules/alb"

  name   = "production-alb"
  vpc_id = "vpc-12345678"
  
  # Security Group automático
  create_security_group = true
  
  security_group_ingress_rules = {
    http = {
      description = "HTTP from internet"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      description = "HTTPS from internet"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  
  security_group_egress_rules = {
    to_targets = {
      description                   = "To target instances"
      from_port                     = 0
      to_port                       = 65535
      ip_protocol                   = "tcp"
      destination_security_group_id = "sg-app-instances-xxx"
    }
  }
  
  subnets = ["subnet-abc123", "subnet-def456"]

  # Múltiples Target Groups
  target_groups = {
    web = {
      name     = "web-tg"
      port     = 80
      protocol = "HTTP"
      health_check = {
        path    = "/"
        matcher = "200"
      }
    }
    api = {
      name     = "api-tg"
      port     = 8080
      protocol = "HTTP"
      health_check = {
        path    = "/health"
        matcher = "200"
      }
      stickiness = {
        type            = "lb_cookie"
        cookie_duration = 86400
        enabled         = true
      }
    }
    admin = {
      name     = "admin-tg"
      port     = 3000
      protocol = "HTTP"
      health_check = {
        path    = "/admin/health"
        matcher = "200-299"
      }
    }
  }

  default_target_group_key = "web"

  # Listeners
  enable_http_listener     = true
  http_redirect_to_https   = true
  enable_https_listener    = true
  certificate_arn          = "arn:aws:acm:us-east-1:123456789:certificate/xxx"

  # Listener Rules
  listener_rules = {
    # FORWARD: API requests
    api_forward = {
      type              = "forward"
      listener_protocol = "HTTPS"
      priority          = 100
      target_group_key  = "api"
      path_pattern      = ["/api/*", "/v1/*"]
    }

    # FORWARD: Admin panel
    admin_forward = {
      type              = "forward"
      listener_protocol = "HTTPS"
      priority          = 200
      target_group_key  = "admin"
      path_pattern      = ["/admin/*"]
      source_ip         = ["10.0.0.0/8"]  # Solo IPs internas
    }

    # REDIRECT: Old domain to new
    domain_redirect = {
      type              = "redirect"
      listener_protocol = "HTTPS"
      priority          = 50
      redirect = {
        host        = "new-domain.com"
        status_code = "HTTP_301"
      }
      host_header = ["old-domain.com"]
    }

    # REDIRECT: Force www
    force_www = {
      type              = "redirect"
      listener_protocol = "HTTPS"
      priority          = 25
      redirect = {
        host        = "www.example.com"
        status_code = "HTTP_301"
      }
      host_header = ["example.com"]
    }

    # REDIRECT: Legacy paths
    legacy_redirect = {
      type              = "redirect"
      listener_protocol = "HTTPS"
      priority          = 150
      redirect = {
        path        = "/new-blog/#{path}"
        status_code = "HTTP_301"
      }
      path_pattern = ["/blog/*", "/articles/*"]
    }
  }

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

## 📊 Condiciones Disponibles

Todas las condiciones se pueden usar tanto en rules de tipo `forward` como `redirect`:

| Condición | Descripción | Ejemplo |
|-----------|-------------|---------|
| `path_pattern` | Patrón del path de la URL | `["/api/*", "/v1/*"]` |
| `host_header` | Host header de la solicitud | `["*.example.com"]` |
| `http_header` | Header HTTP personalizado | `{name = "X-Custom", values = ["value1"]}` |
| `http_request_method` | Método HTTP | `["GET", "POST"]` |
| `query_string` | Parámetros query string | `[{key = "id", value = "123"}]` |
| `source_ip` | IP de origen | `["192.168.1.0/24"]` |

## 🔐 Certificados SSL/TLS Adicionales

```hcl
module "alb" {
  source = "./modules/alb"
  
  # ... otras configuraciones ...

  certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/primary"
  
  additional_certificates = {
    domain2 = "arn:aws:acm:us-east-1:123456789:certificate/domain2"
    domain3 = "arn:aws:acm:us-east-1:123456789:certificate/domain3"
  }
}
```

## 📝 Variables Principales

### Required

- `name` - Nombre del ALB
- `vpc_id` - VPC ID
- `subnets` - Lista de subnet IDs (mínimo 2)
- `target_groups` - Mapa de target groups
- `default_target_group_key` - Target group por defecto

### Security Groups (uno de estos es requerido)

- `create_security_group` - Crear SG automático (default: `false`)
- `security_group_ids` - IDs de SGs existentes (si `create_security_group = false`)
- `security_group_ingress_rules` - Reglas de ingress (si `create_security_group = true`)
- `security_group_egress_rules` - Reglas de egress (si `create_security_group = true`)
- `additional_security_group_ids` - SGs adicionales (opcional)

### Optional

- `internal` - ALB interno (default: `false`)
- `enable_http_listener` - Habilitar HTTP (default: `true`)
- `enable_https_listener` - Habilitar HTTPS (default: `true`)
- `http_redirect_to_https` - Redirect HTTP→HTTPS (default: `true`)
- `listener_rules` - Mapa de reglas (default: `{}`)
- `ssl_policy` - Política SSL (default: `ELBSecurityPolicy-TLS13-1-2-2021-06`)
- `access_logs_enabled` - Habilitar logs (default: `false`)

Ver `variables.tf` para la lista completa.

## 📤 Outputs

### Security Group
- `security_group_id` - ID del SG creado (null si no se creó)
- `security_group_arn` - ARN del SG creado
- `security_group_name` - Nombre del SG creado
- `all_security_group_ids` - Lista de todos los SG IDs del ALB

### ALB
- `alb_dns_name` - DNS del ALB
- `alb_arn` - ARN del ALB
- `target_group_arns` - Mapa de ARNs de target groups
- `http_listener_arn` - ARN listener HTTP
- `https_listener_arn` - ARN listener HTTPS

### Rules
- `forward_rules` - Información de reglas forward
- `redirect_rules` - Información de reglas redirect

Ver `outputs.tf` para la lista completa.

## 🎯 Prioridades de Rules

Las prioridades determinan el orden de evaluación (menor = primero):

```
1-49    → Redirects críticos (ej: HTTP→HTTPS)
50-99   → Redirects de dominio
100-199 → Forward rules principales
200-299 → Forward rules secundarias
300+    → Forward rules específicas
```

## 💡 Mejores Prácticas

### Security Groups
1. **Desarrollo/Testing**: Usa `create_security_group = true` para prototipado rápido
2. **Producción**: Considera usar SGs existentes y gestionados centralmente
3. **Principio de menor privilegio**: Solo abre los puertos necesarios
4. **Egress específico**: Define reglas de egress específicas hacia tus targets (no uses `0.0.0.0/0` en producción)
5. **Documentación**: Usa `description` descriptivas en cada regla

### ALB General
1. **Prioridades**: Asigna prioridades bajas a reglas críticas
2. **Redirects 301 vs 302**: Usa 301 para permanentes, 302 para temporales
3. **Health Checks**: Ajusta intervalos según tu aplicación
4. **Sticky Sessions**: Úsalas solo cuando sea necesario
5. **SSL Policy**: Mantén actualizada la política SSL
6. **Target Groups**: Separa lógicamente tus aplicaciones

## 🐛 Troubleshooting

### Error: "Listener not found"
Verifica que `enable_http_listener` o `enable_https_listener` estén en `true` según el `listener_protocol` de tus rules.

### Error: "Target group not found"
Asegúrate que el `target_group_key` en tus rules existe en el mapa `target_groups`.

### Error: "Security group not found"
- Si `create_security_group = false`, verifica que `security_group_ids` contenga IDs válidos
- Si `create_security_group = true`, asegúrate de no pasar también `security_group_ids`

### Error: "Invalid security group rule"
- Verifica que `cidr_ipv4`, `source_security_group_id`, o `prefix_list_id` estén correctamente definidos
- Solo puedes usar UNO de estos tres campos por regla

### Redirect loop
Revisa que no tengas reglas redirect circulares o que redirigen al mismo destino.

### SG egress no funciona
Si creas el SG automáticamente, asegúrate de definir reglas de egress hacia tus target groups o usa `0.0.0.0/0` temporalmente para debugging.

## 📄 Licencia

Este módulo es de código abierto y está disponible bajo la licencia MIT.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor abre un issue o pull request.