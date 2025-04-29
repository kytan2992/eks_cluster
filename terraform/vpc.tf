module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  public_subnet_names  = ["${local.name_prefix}-public-1a", "${local.name_prefix}-public-1b", "${local.name_prefix}-public-1c"]
  private_subnet_names = ["${local.name_prefix}-private-1a", "${local.name_prefix}-private-1b", "${local.name_prefix}-private-1c"]

  enable_dns_hostnames    = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true

  tags = {
    Terraform = "true"
  }

}