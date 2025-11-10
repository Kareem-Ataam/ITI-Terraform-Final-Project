module "vpc" {
  source                      = "./modules/vpc"
  vpc_cidr_block              = var.vpc_cidr_block
  public_subnet_1_cidr_block  = var.public_subnet_1_cidr_block
  public_subnet_2_cidr_block  = var.public_subnet_2_cidr_block
  private_subnet_1_cidr_block = var.private_subnet_1_cidr_block
  private_subnet_2_cidr_block = var.private_subnet_2_cidr_block
  internal_alb_sg_id          = module.alb.internal_alb_sg_id
}
module "instances" {
  source                 = "./modules/instances"
  public_subnet_ids      = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  private_subnet_ids     = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  public_instance_sg_id  = module.vpc.public_instance_sg_id
  private_instance_sg_id = module.vpc.private_instance_sg_id
  key_pair_name          = var.key_pair_name
  public_key_path        = var.public_key_path
  private_key_path       = var.private_key_path
  public_instance_type   = var.public_instance_type
  private_instance_type  = var.private_instance_type
  private_alb_dns_name   = module.alb.private_alb_dns_name
  depends_on             = [module.vpc]
}
module "alb" {
  source               = "./modules/alb"
  vpc_id               = module.vpc.vpc_id
  public_subnets       = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  public_instance_ids  = module.instances.public_instance_ids
  private_instance_ids = module.instances.private_instance_ids
  rev_proxy_sg_id      = module.vpc.public_instance_sg_id
  private_subnets      = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
}
