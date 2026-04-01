This is a Terraform Module for AWS VPC, Its resuable, We can invoke and use it in below way:

module "vpc1" {
  source = "./modules/vpc"

  name = "vpc-1"
  cidr = "10.0.0.0/16"

  azs = ["ap-south-1a"]

  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]
  tgw_subnets     = ["10.0.3.0/24"]

  enable_nat = false
}

Since we have given single AZS and Single request for each subnet, Each subnet will be deployed in Region : "ap-south-1a".
For maximum availability is recommended to invoke with atleast 2 AZS and 2 CIDR for required subnets.
