output "oidc_provider_url_cleaned" {
  value = replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")
}