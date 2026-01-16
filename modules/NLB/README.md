# Módulo Terraform - AWS Network Load Balancer (NLB)

Módulo profesional de Terraform para el despliegue y gestión de AWS Network Load Balancers con soporte completo para Target Groups, Health Checks, Listeners y configuraciones avanzadas.

## Características

- ✅ Creación de Network Load Balancer (interno o público)
- ✅ Soporte para múltiples Target Groups con configuración personalizable
- ✅ Health Checks configurables por Target Group
- ✅ Gestión de targets (instancias EC2, IPs, ALBs, etc.)
- ✅ Listeners con soporte TCP, TLS, UDP y TCP_UDP
- ✅ Logs de acceso en S3
- ✅ Cross-zone load balancing
- ✅ Integración opcional con Security Groups
- ✅ Stickiness por Target Group
- ✅ Protección contra eliminación
- ✅ Tags personalizables

## Uso Básico

```hcl
module "nlb" {
  source = "./modules/nlb"

  name     = "my-nlb"
  internal = false
  subnets  = ["subnet-12345", "subnet-67890"]
  vpc_id   = "vpc-12345678"

  # Target Groups
  target_groups = {
    web = {
      port     = 80
      protocol = "TCP"
      
      health_check = {
        enabled             = true
        interval            = 30
        protocol            = "TCP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
      
      targets = [
        {
          target_id = "i-1234567890abcdef0"
          port      = 80
        },
        {
          target_id = "i-0987654321fedcba0"
          port      = 80
        }
      ]
    }
  }

  # Listeners
  listeners = {
    web = {
      port             = 80
      protocol         = "TCP"
      target_group_key = "web"
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Ejemplo con ALB como Target

```hcl
module "nlb" {
  source = "./modules/nlb"

  name     = "nlb-to-alb"
  internal = true
  subnets  = ["subnet-12345", "subnet-67890"]
  vpc_id   = "vpc-12345678"

  # Habilitar cross-zone load balancing
  enable_cross_zone_load_balancing = true

  # Security Group (opcional)
  security_group_id = "sg-12345678"

  target_groups = {
    alb = {
      port        = 8080
      protocol    = "TCP"
      target_type = "alb"
      
      health_check = {
        enabled   = true
        interval  = 10
        protocol  = "TCP"
        timeout   = 10
      }
      
      targets = [
        {
          target_id = module.alb[0].alb_arn
          port      = 8080
        }
      ]
    }
  }

  listeners = {
    main = {
      port             = 80
      protocol         = "TCP"
      target_group_key = "alb"
    }
  }
}
```

## Ejemplo con TLS Listener y Logs en S3

```hcl
module "nlb" {
  source = "./modules/nlb"

  name     = "secure-nlb"
  internal = false
  subnets  = ["subnet-12345", "subnet-67890"]
  vpc_id   = "vpc-12345678"

  # Configuración de logs
  enable_access_logs  = true
  access_logs_bucket  = "my-nlb-logs-bucket"
  access_logs_prefix  = "nlb-logs/"

  # Protección contra eliminación
  enable_deletion_protection = true

  target_groups = {
    secure = {
      port     = 443
      protocol = "TCP"
      
      health_check = {
        enabled   = true
        interval  = 30
        protocol  = "TCP"
      }
      
      stickiness = {
        enabled = true
        type    = "source_ip"
      }
      
      targets = [
        {
          target_id = "10.0.1.100"
          port      = 443
        },
        {
          target_id = "10.0.2.100"
          port      = 443
        }
      ]
    }
  }

  listeners = {
    https = {
      port             = 443
      protocol         = "TLS"
      certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-1234"
      ssl_policy       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      target_group_key = "secure"
    }
  }

  tags = {
    Environment = "production"
    Compliance  = "PCI-DSS"
  }
}
```

## Ejemplo Avanzado - Múltiples Target Groups y Listeners

```hcl
module "nlb" {
  source = "./modules/nlb"

  name     = "multi-service-nlb"
  internal = false
  subnets  = ["subnet-12345", "subnet-67890"]
  vpc_id   = "vpc-12345678"

  enable_cross_zone_load_balancing = true
  security_group_id                = "sg-12345678"

  target_groups = {
    web = {
      port        = 80
      protocol    = "TCP"
      target_type = "instance"
      
      health_check = {
        enabled             = true
        interval            = 30
        protocol            = "HTTP"
        port                = "80"
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
      
      targets = [
        { target_id = "i-111111", port = 80 },
        { target_id = "i-222222", port = 80 }
      ]
    }
    
    api = {
      port                 = 8080
      protocol             = "TCP"
      target_type          = "instance"
      deregistration_delay = 60
      
      health_check = {
        enabled   = true
        interval  = 10
        protocol  = "TCP"
      }
      
      targets = [
        { target_id = "i-333333", port = 8080 },
        { target_id = "i-444444", port = 8080 }
      ]
    }
    
    database = {
      port        = 5432
      protocol    = "TCP"
      target_type = "ip"
      
      health_check = {
        enabled  = true
        interval = 30
        protocol = "TCP"
      }
      
      targets = [
        { target_id = "10.0.1.50", port = 5432 },
        { target_id = "10.0.2.50", port = 5432 }
      ]
    }
  }

  listeners = {
    http = {
      port             = 80
      protocol         = "TCP"
      target_group_key = "web"
    }
    
    api = {
      port             = 8080
      protocol         = "TCP"
      target_group_key = "api"
    }
    
    db = {
      port             = 5432
      protocol         = "TCP"
      target_group_key = "database"
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Variable | Tipo | Descripción | Requerido | Default |
|----------|------|-------------|-----------|---------|
| `name` | `string` | Nombre del Network Load Balancer | Sí | - |
| `vpc_id` | `string` | ID de la VPC donde se crearán los Target Groups | Sí | - |
| `subnets` | `list(string)` | Lista de IDs de subnets donde se desplegará el NLB | Sí | - |
| `internal` | `bool` | Si el NLB debe ser interno (true) o público (false) | No | `false` |
| `enable_deletion_protection` | `bool` | Habilitar protección contra eliminación | No | `false` |
| `enable_cross_zone_load_balancing` | `bool` | Habilitar balanceo de carga entre zonas de disponibilidad | No | `true` |
| `security_group_id` | `string` | ID del Security Group a asociar al NLB (opcional) | No | `null` |
| `enable_access_logs` | `bool` | Habilitar logs de acceso en S3 | No | `false` |
| `access_logs_bucket` | `string` | Nombre del bucket S3 para almacenar logs de acceso | No | `""` |
| `access_logs_prefix` | `string` | Prefijo para los logs en el bucket S3 | No | `""` |
| `ip_address_type` | `string` | Tipo de dirección IP (ipv4 o dualstack) | No | `"ipv4"` |
| `target_groups` | `map(object)` | Mapa de Target Groups con sus configuraciones | No | `{}` |
| `listeners` | `map(object)` | Mapa de Listeners a crear | No | `{}` |
| `tags` | `map(string)` | Tags a aplicar a todos los recursos | No | `{}` |

### Estructura de `target_groups`

```hcl
target_groups = {
  "nombre_tg" = {
    port                 = number        # Puerto del target group (requerido)
    protocol             = string        # TCP, TLS, UDP o TCP_UDP (requerido)
    target_type          = string        # instance, ip o alb (opcional, default: "instance")
    deregistration_delay = number        # Tiempo en segundos (opcional, default: 300)
    
    health_check = {
      enabled             = bool         # (opcional, default: true)
      interval            = number       # Segundos entre checks (opcional, default: 30)
      port                = string       # Puerto o "traffic-port" (opcional, default: "traffic-port")
      protocol            = string       # TCP, HTTP o HTTPS (opcional, default: "TCP")
      healthy_threshold   = number       # (opcional, default: 3)
      unhealthy_threshold = number       # (opcional, default: 3)
      timeout             = number       # Segundos (opcional, default: 10)
    }
    
    stickiness = {                       # (opcional)
      enabled = bool                     # (opcional, default: false)
      type    = string                   # "source_ip" para NLB (opcional)
    }
    
    targets = [
      {
        target_id         = string       # ID de instancia, IP o ARN de ALB (requerido)
        port              = number       # Puerto del target (opcional)
        availability_zone = string       # AZ específica o "all" (opcional, default: "all")
      }
    ]
  }
}
```

### Estructura de `listeners`

```hcl
listeners = {
  "nombre_listener" = {
    port             = number            # Puerto del listener (requerido)
    protocol         = string            # TCP, TLS, UDP o TCP_UDP (requerido)
    certificate_arn  = string            # ARN del certificado ACM para TLS (opcional)
    alpn_policy      = string            # Política ALPN (opcional)
    ssl_policy       = string            # Política SSL (opcional, default: "ELBSecurityPolicy-TLS13-1-2-2021-06")
    target_group_key = string            # Key del target group en el mapa (requerido)
  }
}
```

## Outputs

| Output | Tipo | Descripción |
|--------|------|-------------|
| `nlb_id` | `string` | ID del Network Load Balancer |
| `nlb_arn` | `string` | ARN del Network Load Balancer |
| `nlb_arn_suffix` | `string` | ARN suffix del NLB para métricas de CloudWatch |
| `nlb_dns_name` | `string` | Nombre DNS del Network Load Balancer |
| `nlb_zone_id` | `string` | Zone ID canónico del NLB (para Route53) |
| `target_group_arns` | `map(string)` | Mapa de ARNs de los Target Groups creados |
| `target_group_ids` | `map(string)` | Mapa de IDs de los Target Groups creados |
| `target_group_arn_suffixes` | `map(string)` | Mapa de ARN suffixes de los Target Groups |
| `target_group_names` | `map(string)` | Mapa de nombres de los Target Groups creados |
| `listener_arns` | `map(string)` | Mapa de ARNs de los Listeners creados |
| `listener_ids` | `map(string)` | Mapa de IDs de los Listeners creados |

## Ejemplo de Uso de Outputs

```hcl
# Usar el DNS del NLB en Route53
resource "aws_route53_record" "nlb" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "app.example.com"
  type    = "A"

  alias {
    name                   = module.nlb.nlb_dns_name
    zone_id                = module.nlb.nlb_zone_id
    evaluate_target_health = true
  }
}

# Usar el ARN del Target Group en autoscaling
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  lb_target_group_arn    = module.nlb.target_group_arns["web"]
}

# Crear alarmas de CloudWatch
resource "aws_cloudwatch_metric_alarm" "nlb_unhealthy_hosts" {
  alarm_name          = "nlb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/NetworkELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  
  dimensions = {
    LoadBalancer = module.nlb.nlb_arn_suffix
    TargetGroup  = module.nlb.target_group_arn_suffixes["web"]
  }
}
```

## Notas Importantes

### Security Groups
- Los Security Groups en NLB son opcionales y solo están disponibles en NLBs con tipo de IP `ipv4` o `dualstack`.
- Este módulo **NO crea** Security Groups. Debes proporcionar un ID existente mediante `security_group_id`.
- Si no se proporciona un Security Group, el NLB permitirá todo el tráfico por defecto.

### Target Types
- **instance**: Targets son instancias EC2 (identificadas por Instance ID)
- **ip**: Targets son direcciones IP (dentro de la VPC o en redes conectadas)
- **alb**: Targets son Application Load Balancers (identificados por ARN del ALB)

### Cross-Zone Load Balancing
- Habilitado por defecto (`enable_cross_zone_load_balancing = true`)
- Distribuye el tráfico uniformemente entre todos los targets en todas las zonas de disponibilidad
- Deshabilitarlo puede reducir costos de transferencia de datos entre zonas

### Access Logs
- Requiere que el bucket S3 tenga la política de bucket correcta
- AWS requiere permisos específicos para escribir logs en S3
- Ejemplo de política de bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticloadbalancing.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-nlb-logs-bucket/*"
    }
  ]
}
```

### Health Checks
- **TCP**: Verifica que el puerto está abierto
- **HTTP/HTTPS**: Verifica código de respuesta HTTP 200-399
- El protocolo del health check puede ser diferente al protocolo del Target Group
- Para Target Groups TCP, se recomienda usar health checks TCP por simplicidad

### Stickiness
- Solo disponible para Target Groups con protocolo TCP o TLS
- Tipo `source_ip`: Mantiene conexiones de la misma IP de origen al mismo target
- La duración de la stickiness es de 5 minutos y no es configurable en NLB

## Requisitos

- Terraform >= 1.0
- AWS Provider >= 5.0

## Autores

Módulo desarrollado y mantenido por el equipo de infraestructura.

## Licencia

MIT License