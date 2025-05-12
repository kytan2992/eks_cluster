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
    "AmazonEKSVPCResourceController" = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  }

  eks_managed_node_groups = {
    ky-tf-node-group = {
      max_size       = 5
      min_size       = 3
      desired_size   = 3
      instance_types = ["t3.medium"]

      tags = {
        Name                                                     = "${local.name_prefix}-node-group"
        "k8s.io/cluster-autoscaler/enabled"                      = "true"
        "k8s.io/cluster-autoscaler/${local.name_prefix}-cluster" = "owned"
      }
    }
  }
  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

## Create the namespace for the application

# resource "kubernetes_namespace" "namespace" {
#   metadata {
#     name = "${local.name_prefix}-capstone"
#   }
# }

# Create VPC Endpoints for EKS CLuster to connect to ECR
# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = module.vpc.vpc_id
#   service_name        = "com.amazonaws.us-east-1.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = module.vpc.private_subnets
#   security_group_ids  = [module.eks.node_security_group_id]
#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = module.vpc.vpc_id
#   service_name        = "com.amazonaws.us-east-1.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = module.vpc.private_subnets
#   security_group_ids  = [module.eks.node_security_group_id]
#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ecr_s3" {
#   vpc_id            = module.vpc.vpc_id
#   service_name      = "com.amazonaws.us-east-1.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = module.vpc.private_route_table_ids
# }