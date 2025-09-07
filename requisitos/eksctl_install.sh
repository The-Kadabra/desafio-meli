#!/bin/bash
set -e

cluster_name="desafio"

echo "=== Buscando OIDC ID do cluster $cluster_name ==="
oidc_id=$(aws eks describe-cluster \
  --name "$cluster_name" \
  --query "cluster.identity.oidc.issuer" \
  --output text | cut -d '/' -f 5)

echo "OIDC ID: $oidc_id"

echo "=== Conferindo se já existe OIDC provider associado ==="
aws iam list-open-id-connect-providers | grep "$oidc_id" | cut -d "/" -f4 || true

echo "=== Associando OIDC provider ao cluster (se necessário) ==="
eksctl utils associate-iam-oidc-provider --cluster "$cluster_name" --approve

echo "=== Instalando Helm ==="
wget https://get.helm.sh/helm-v4.0.0-alpha.1-linux-amd64.tar.gz
tar -zxvf helm-v4.0.0-alpha.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

echo "Helm instalado com sucesso!"
