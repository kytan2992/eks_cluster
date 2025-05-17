terraform {
  backend "s3" {
    bucket = "ky-s3-terraform"           ## change to your bucket name
    key    = "avengers-capstone.tfstate" ## change to your key name
    region = "us-east-1"
  }
}
