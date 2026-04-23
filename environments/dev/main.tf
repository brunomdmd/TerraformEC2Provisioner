terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "terraformec2provisioner-bmd"
    key     = "qa/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
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
  vpc_id      = module.vpc.vpc_id
  cidr_ipv4   = module.vpc.aws_vpc_cidr_block
  environment = var.environment
  myip        = var.myip
}

module "ec2" {
  source            = "../../modules/ec2"
  ami_id            = data.aws_ami.amazon_linux_2023.id
  instance_count    = var.instance_count
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.vpc.subnet_public_id
  security_group_id = [module.security_group.security_group_id]
  environment       = var.environment
}
