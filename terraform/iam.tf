## Policy for ExternalDNS to manage Route53 records

resource "aws_iam_policy" "externaldns" {
  name        = "${local.name_prefix}-ExternalDNSPolicy"
  description = "Policy for ExternalDNS to manage Route53 records"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets"
        ],
        Resource = ["arn:aws:route53:::hostedzone/*"]
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        Resource = ["*"]
      }
    ]
  })
}

## IAM Role for ExternalDNS

resource "aws_iam_role" "externaldns" {
  name = "${local.name_prefix}-ExternalDNSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:default:external-dns", ## "default" is the namespace created using helm if not specified, change if needed
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "externaldns_attach" {
  role       = aws_iam_role.externaldns.name
  policy_arn = aws_iam_policy.externaldns.arn
}

