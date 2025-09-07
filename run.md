# Como executar o projeto



## 1-) Instalando os requisitos

Este script foi projetado para automatizar a instalação e configuração de um ambiente de desenvolvimento focado em DevOps, Cloud e conteinerização em um sistema operacional baseado em Debian/Ubuntu.

Antes de executa-lo não se esqueça do comando `chmod +x requisitos.sh`. Veja o conteúdo: [Requisitos](requisitos/requisitos.sh)

Ao executar este script, as seguintes ferramentas serão instaladas e configuradas no seu computador:
- ``Git`` 
- ``Python 3.8``
- ``Terraform``
- ``Docker e Docker Compose``
- ``kubectl (v1.33.3)``
- ``Helm (v4.0.0-alpha.1)``
- ``AWS EKS (v1.33)``




## 2-) Executando o terraform plan/apply:

Primeiro:
- Execute o comando que vai permitir o seu terraform a interagir com o a lib do docker em seu computador local (isso é necessario para o ECR): \
`newgrp docker`

- Segundo: Vamos construir as fundações do projeto, ou seja, a rede: \
``terraform plan -target=module.vpc`` \
``terraform apply -target=module.vpc`` 

- Terceiro: Aqui o seu cluster, node, addons, permissionamentos serão criados e associados. \
``terraform plan -target=module.eks`` \
``terraform apply -target=module.eks`` 

- Ultimo passo: \
``terraform plan`` Aqui vms criar todo o resto do conteudo funcional da sua infraestrutura aws.\
``terraform apply``


## 3-) Uso diario e cuidado ao criar um CI/CD
O token de comunicação do EKS é curto (default aws), caso vc tenha problemas relacionados á:
```text
 a- ) Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with helm_release.argocd,
│   on main.tf line 1, in resource "helm_release" "argocd":
│    1: resource "helm_release" "argocd" {}

b- ) Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with helm_release.ingress_nginx,
│   on main.tf line 32, in resource "helm_release" "ingress_nginx":
│   32: resource "helm_release" "ingress_nginx" {}
c- ) Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with module.eks_blueprints_addons.module.aws_load_balancer_controller.helm_release.this[0],
│   on .terraform/modules/eks_blueprints_addons.aws_load_balancer_controller/main.tf line 9, in resource "helm_release" "this":
│    9: resource "helm_release" "this" {}

d- ) Kubernetes cluster unreachable: the server has asked for the client to provide credentials
│ 
│   with module.eks_blueprints_addons.module.metrics_server.helm_release.this[0],
│   on .terraform/modules/eks_blueprints_addons.metrics_server/main.tf line 9, in resource "helm_release" "this":
│    9: resource "helm_release" "this" {}
``` 
## 3.1-) Segue a solução:

 Este processo a seguir faz com que um novo token seja gerado e gravado localmente ou pelo CI/CD:

``terraform taint data.aws_eks_cluster_auth.this`` \
``terraform state rm data.aws_eks_cluster_auth.this`` \
``terraform plan --target=data.aws_eks_cluster_auth.this`` \
``terraform apply --target=data.aws_eks_cluster_auth.this --auto-approve`` 


