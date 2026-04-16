provider "aws" {
  region = var.region
}

######################
# VPCs
######################

module "vpc1" {
  source = "../Modules/vpc"

  name = "vpc-1"
  cidr = "10.0.0.0/16"

  azs = ["ap-south-1a"]

  private_subnets = ["10.0.1.0/24"]
  tgw_subnets     = ["10.0.2.0/24"]

  environment = var.environment
}

module "vpc2" {
  source = "./modules/vpc"

  name = "vpc-2"
  cidr = "10.1.0.0/16"

  azs = ["ap-south-1a"]

  private_subnets = ["10.1.1.0/24"]
  tgw_subnets     = ["10.1.2.0/24"]

  environment = var.environment
}

module "inspection_vpc" {
  source = "./modules/vpc"

  name = "inspection-vpc"
  cidr = "10.2.0.0/16"

  azs = ["ap-south-1a"]

  private_subnets = ["10.2.1.0/24"]
  tgw_subnets     = ["10.2.2.0/24"]

  environment = var.environment
}

######################
# TGW
######################

module "tgw" {
  source = "./modules/tgw"
  environment = var.environment
}

######################
# TGW Attachments
######################

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  vpc_id             = module.vpc1.vpc_id
  subnet_ids         = module.vpc1.tgw_subnets
  transit_gateway_id = module.tgw.tgw_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  vpc_id             = module.vpc2.vpc_id
  subnet_ids         = module.vpc2.tgw_subnets
  transit_gateway_id = module.tgw.tgw_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection" {
  vpc_id             = module.inspection_vpc.vpc_id
  subnet_ids         = module.inspection_vpc.tgw_subnets
  transit_gateway_id = module.tgw.tgw_id
}

######################
# TGW Routing
######################

resource "aws_ec2_transit_gateway_route" "default_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = module.tgw.tgw_rt_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
}

######################
# VPC Routes → TGW
######################

resource "aws_route" "vpc1_to_tgw" {
  route_table_id         = module.vpc1.private_rt_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.tgw.tgw_id
}

resource "aws_route" "vpc2_to_tgw" {
  route_table_id         = module.vpc2.private_rt_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.tgw.tgw_id
}

######################
# Internet (Inspection VPC)
######################

resource "aws_internet_gateway" "igw" {
  vpc_id = module.inspection_vpc.vpc_id
}

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  subnet_id     = module.inspection_vpc.tgw_subnets[0]
  allocation_id = aws_eip.nat.id
}

######################
# Security Group
######################

resource "aws_security_group" "allow_all_vpc1" {
  vpc_id = module.vpc1.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######################
# EC2
######################

module "ec2_vpc1" {
  source = "./modules/ec2"

  name      = "ec2-vpc1"
  subnet_id = module.vpc1.private_subnets[0]
  sg_id     = aws_security_group.allow_all_vpc1.id
}
