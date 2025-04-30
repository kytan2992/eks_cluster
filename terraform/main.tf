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

  iam_role_additional_policies = {
    "AmazonEKSVPCResourceController " = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }

  eks_managed_node_groups = {
    ky-tf-node-group = {
      max_size         = 4
      min_size         = 1
      desired_size     = 2

      instance_types = ["t3.medium"]

      tags = {
        Name = "${local.name_prefix}-node-group"
      }
    }
  }
  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

