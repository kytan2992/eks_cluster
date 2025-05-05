module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.1"

  name = "${local.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  public_subnet_names  = ["${local.name_prefix}-public-1a", "${local.name_prefix}-public-1b", "${local.name_prefix}-public-1c"]
  private_subnet_names = ["${local.name_prefix}-private-1a", "${local.name_prefix}-private-1b", "${local.name_prefix}-private-1c"]

  enable_dns_hostnames = true

  ## NAT Gateway is needed since the kubernetes-manifest.yaml needs internet access from private subnets to pull the docker images from
  ## Google Container Registry. If we build the images ourselves and push them to our own ECR, we will need to change all the image values 
  ## in the yaml file and then can remove the NAT Gateway. Might need to add VPC Endpoints and IAM Access to ECR in this case

  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true

  tags = {
    Terraform = "true"
  }

}