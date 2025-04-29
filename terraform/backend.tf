terraform {
  backend "s3" {
    bucket = "ky-s3-terraform"
    key    = "ky-tf-fill-here.tfstate"
    region = "us-east-1"
  }
}
