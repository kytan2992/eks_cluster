locals {
  name_prefix = "ky-tf"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  
  cluster_name    = "${local.name_prefix}-cluster"
  cluster_version = "1.32"

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    ky-tf-node-group = {
      desired_capacity = 2
      max_size         = 3
      min_size         = 1

      instance_type = "t3.micro"

      tags = {
        Name = "${local.name_prefix}-node-group"
      }
    }
  }
  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

