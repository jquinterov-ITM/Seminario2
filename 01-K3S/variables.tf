variable "aws_region" { default = "us-east-1" }
variable "key_name"   { default = "testKey" } # nombre de la llave creada en aws para acceder a las instancias
#variable "my_ip"      { default = "201.233.77.14/32" } # mi ip publica con mascara
variable "my_ip"      { default = "0.0.0.0/0" }

locals {
  envs = {
    "dev" = {
      master_type  = "t3.medium", worker_type = "t3.large"
      vpc_cidr     = "172.20.0.0/23"
      pub_subnets  = ["172.20.0.0/26", "172.20.0.64/26"]
      priv_subnets = ["172.20.0.128/26", "172.20.0.192/26"]
    }
    "prod" = {
      master_type  = "t3.large", worker_type = "c5.xlarge"
      vpc_cidr     = "172.20.2.0/23"
      pub_subnets  = ["172.20.2.0/26", "172.20.2.64/26"]
      priv_subnets = ["172.20.2.128/26", "172.20.2.192/26"]
    }
  }
  current_env = contains(keys(local.envs), terraform.workspace) ? terraform.workspace : "dev"
  config      = local.envs[local.current_env]
  k3s_token   = "K3s-Secret-2026-Token"
}