terraform {
  backend "s3" {
    bucket = "ky-s3-terraform"
    key    = "ky-tf-eks-cluster.tfstate"
    region = "us-east-1"
  }
}
