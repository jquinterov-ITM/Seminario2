module "database" {
  source                = "./modules/db"
  vpc_id                = data.aws_vpc.main.id
  subnet_ids            = data.aws_subnets.private.ids
  worker_sg_id          = data.aws_security_group.worker_sg.id
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_password           = var.db_password
}

module "storage" {
  source             = "./modules/storage"
  vpc_id             = data.aws_vpc.main.id
  subnet_ids         = data.aws_subnets.private.ids
  worker_sg_id       = data.aws_security_group.worker_sg.id
}