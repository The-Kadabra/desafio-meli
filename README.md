# desafio-meli



executando o terraform plan/apply:

Primeiro:
Execute o comando que vai perdir o seu terraform a interagir com o DOCKER (isso é necessario para o ECR).
newgrp docker

Segundo:
terraform plan -target=module.vpc
terraform apply -target=module.vpc

Terceiro:
terraform plan -target=module.eks
terraform apply -target=module.eks

Ultimo passo:
terraform plan
terraform apply


# Uso diario e cuidado ao criar um CI/CD
O token de comunicação do EKS é curto, caso vc tenha problemas relacionados á:
1) Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with helm_release.argocd,
│   on main.tf line 1, in resource "helm_release" "argocd":
│    1: resource "helm_release" "argocd" {}

2) Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with helm_release.ingress_nginx,
│   on main.tf line 32, in resource "helm_release" "ingress_nginx":
│   32: resource "helm_release" "ingress_nginx" {}

3) Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with module.eks_blueprints_addons.module.aws_load_balancer_controller.helm_release.this[0],
│   on .terraform/modules/eks_blueprints_addons.aws_load_balancer_controller/main.tf line 9, in resource "helm_release" "this":
│    9: resource "helm_release" "this" {}

4) Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with module.eks_blueprints_addons.module.metrics_server.helm_release.this[0],
│   on .terraform/modules/eks_blueprints_addons.metrics_server/main.tf line 9, in resource "helm_release" "this":
│    9: resource "helm_release" "this" {}

Segue a solução: Este processo a seguir faz com que um novo token seja gerado e gravado localmente ou pelo CI/CD.
terraform taint data.aws_eks_cluster_auth.this
terraform state rm data.aws_eks_cluster_auth.this
terraform plan --target=data.aws_eks_cluster_auth.this
terraform apply --target=data.aws_eks_cluster_auth.this --auto-approve
