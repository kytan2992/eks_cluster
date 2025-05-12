# data "aws_eks_cluster" "aws_eks_cluster" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = data.aws_eks_cluster.aws_eks_cluster.name
# }

data "aws_availability_zones" "available" {
  state = "available"
}
