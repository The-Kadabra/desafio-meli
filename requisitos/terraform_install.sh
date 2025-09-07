#!/bin/bash
set -e

echo "=== 1. Atualizando pacotes e instalando dependências ==="
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

echo "=== 2. Adicionando chave GPG da HashiCorp ==="
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "=== 3. Adicionando repositório oficial da HashiCorp ==="
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "=== 4. Atualizando lista de pacotes ==="
sudo apt-get update

echo "=== 5. Instalando Terraform ==="
sudo apt-get install terraform -y

echo "=== 6. Verificando versão instalada ==="
terraform -version
