terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-awsstudybruno"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


locals {
  ami_filters = {
    AMAZON_LINUX_2023 = {
      name   = ["al2023-ami-*-x86_64"]
      owner  = "amazon"
    }
    UBUNTU_24_04 = {
      name   = ["ubuntu/images/hvm-ssd-gp3/ubuntu-*-24.04-amd64-server-*"]
      owner  = "099720109477"
    }
    UBUNTU_22_04 = {
      name   = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
      owner  = "099720109477"
    }
    WINDOWS_2022 = {
      name   = ["Windows_Server-2022-English-Full-Base-*"]
      owner  = "amazon"
    }
    WINDOWS_2019 = {
      name   = ["Windows_Server-2019-English-Full-Base-*"]
      owner  = "amazon"
    }
  }
}

data "aws_ami" "selected" {
  most_recent = true
  owners      = [local.ami_filters[var.os_type].owner]

  filter {
    name   = "name"
    values = local.ami_filters[var.os_type].name
  }
}


module "vpc" {
  source              = "../../modules/vpc"
  block_cidr          = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
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
  ami_id            = data.aws_ami.selected.id
  os_type           = var.os_type
  instance_count    = var.instance_count
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.vpc.subnet_public_id
  security_group_id = [module.security_group.security_group_id]
  environment       = var.environment
}
