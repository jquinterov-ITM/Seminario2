locals {
  # Asegúrate que estas CIDR coincidan EXACTAMENTE con lo que definiste en la carpeta 01
  env_vpc_cidr = {
    dev  = "172.20.0.0/23" 
    prod = "172.20.2.0/23"
  }
  # Si no usas workspaces, puedes forzarlo a "dev"
  current_env = terraform.workspace == "default" ? "dev" : terraform.workspace
}

# 1. Busca la VPC que ya existe
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["VPC-${local.current_env}"]
  }
}

# 2. Busca las subredes privadas ya creadas (donde irá la DB)
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["Private-${local.current_env}-*"]
  }
}

# 3. Busca el Security Group de los Workers para darle acceso a la DB
data "aws_security_group" "worker_sg" {
  filter {
    name   = "group-name"
    values = ["SG-Worker-${local.current_env}"]
  }
  vpc_id = data.aws_vpc.main.id
}