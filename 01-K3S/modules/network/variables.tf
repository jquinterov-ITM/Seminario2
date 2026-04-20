variable "vpc_cidr" {
  description = "Rango CIDR para la VPC"
  type        = string
}

variable "pub_subnets" {
  description = "Lista de CIDRs para subredes públicas"
  type        = list(string)
}

variable "priv_subnets" {
  description = "Lista de CIDRs para subredes privadas"
  type        = list(string)
}

variable "env" {
  description = "Nombre del entorno (dev/prod)"
  type        = string
}