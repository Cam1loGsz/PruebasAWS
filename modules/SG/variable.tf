variable "name" {
    type        = string
    description = "Security group name"
}
variable "description" {
    type        = string
    description = "Security group description"
}
variable "vpc_id" {
    type        = string
    description = "VPC ID"
}
variable "ingress_rules" {
  description = "Mapa de reglas ingress"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    security_groups  = optional(list(string))
    prefix_list_id   = optional(list(string))
    self             = optional(bool)
    description      = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "Mapa de reglas egress"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    security_groups  = optional(list(string))
    self             = optional(bool)
    prefix_list_id   = optional(list(string))
    description      = optional(string)
  }))
  default = []
  
}