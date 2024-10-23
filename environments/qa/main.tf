
provider "aws" {
  region = "us-east-1"
}

# State file
terraform {
  backend "s3" {
    bucket  = "terraform-bmd" #Mudar para o seu bucket
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


module "vpc" {
  source              = "../../modules/vpc"
  block_cidr          = "172.16.0.0/16"
  public_subnet_cidr  = "172.16.1.0/24"
  private_subnet_cidr = "172.16.2.0/24"
  az                  = "us-east-1a"
  environment         = var.environment
}

module "security_group" {
  source      = "../../modules/security_group"
  vpc_id = module.vpc.vpc_id
  cidr_ipv4 = module.vpc.aws_vpc_cidr_block
  environment = var.environment
}


module "ec2" {
  source            = "../../modules/ec2"
  ami_id            = "ami-06b21ccaeff8cd686"
  instance_count    = 1
  instance_type     = "t2.nano"
  key_name          = "QA-KEY"
  subnet_id         = module.vpc.subnet_public_id
  security_group_id = [module.security_group.security_group_id]
  environment       = var.environment
}
