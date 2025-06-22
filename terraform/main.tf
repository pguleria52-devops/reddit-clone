terraform {
  backend "s3" {
    bucket = "qazxswedc-12.20-25"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "security"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  availability_zones = var.availability_zones
  cidr_block = var.vpc_cidr
  private_subnet = var.private_subnets
  public_subnet = var.public_subnets
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"
  cluster_version = var.cluster-version
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet
  node_group = var.node_group
}