output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "externaldns_role_arn" {
  value = aws_iam_role.externaldns.arn
}