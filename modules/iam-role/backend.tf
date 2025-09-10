terraform {
  backend "s3" {
    bucket  = "eks-terraform-terotam"
    key     = "eks/sandbox/iam.tfstate" # Unique state file per cluster
    region  = "ap-south-1"
    encrypt = true
  }
}

terraform {
  required_version = "=1.12.1"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "=5.98.0"
      version = "=6.5.0"
    }

    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.17.0"
    # }
    #  kubectl = {
    #   source  = "gavinbunney/kubectl"
    #   version = "~> 1.19.0"
    # }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "2.36.0"
    # }

  }
}