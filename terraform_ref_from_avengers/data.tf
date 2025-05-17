data "aws_eks_cluster" "cluster" {
  name = "Avengers-eks-cluster"
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}