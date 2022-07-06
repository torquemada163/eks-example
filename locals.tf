locals {
  name            = "eks-example"
  cluster_version = "1.22"
  region          = "us-west-2"
  tags = {
    createdby = "terraform"
  }
}