locals {
  name_prefix = var.name_prefix
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${local.name_prefix}-cluster"
  cluster_version = "1.32"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  bootstrap_self_managed_addons = true
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  ## Allow IAM role to view cluster resources on the console
  ## Might need to manually add the rest of the group using the console since now only the person creating the cluster have viewing access
  iam_role_additional_policies = {
    "AmazonEKSVPCResourceController " = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }

  eks_managed_node_groups = {
    group-2-node-group = {
      ami_type       = "AL2023_x86_64_STANDARD"
      max_size       = 5
      min_size       = 3
      desired_size   = 3
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

## Create the namespace for the application

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.name_prefix}-capstone"
  }
}
