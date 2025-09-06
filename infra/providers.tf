terraform {
    backend "s3" {
    bucket         = "tfstate-desafio-505838347528" #Não é possivel passar env ou apontamente de recurso
    key            = "global/terraform-meli-api-desafio.tfstate"   
    region         = "us-east-1"
    encrypt        = true                                   
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
  required_version = ">= 1.5.7"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}