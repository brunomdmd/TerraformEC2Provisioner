
provider "aws" {
  region = "us-east-1"
}

# State file
terraform {
  backend "s3" {
    bucket  = "terraform-bmd"
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
  my_ip       = ["XXX.XXX.XX.XX/32"]
  vpc_id = module.vpc.vpc_id
  environment = var.environment
}

module "key_pair" {
  source   = "../../modules/key_pair"
  key_name = "qa-key.pub"
  key_path = "../../environments/qa/qa-key.pub"
}

module "ec2" {
  source            = "../../modules/ec2"
  ami_id            = "ami-06b21ccaeff8cd686"
  instance_count    = 2
  instance_type     = "t2.micro"
  key_name          = "qa-key.pub"
  subnet_id         = module.vpc.subnet_public_id
  security_group_id = [module.security_group.security_group_id]
  environment       = var.environment
}
