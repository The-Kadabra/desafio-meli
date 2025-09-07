#!/bin/bash
set -e

echo "================================================="
echo "=== INICIANDO SCRIPT DE INSTALAÇÃO COMPLETO ==="
echo "================================================="

#-------------------------------------------------
# 1. ATUALIZANDO PACOTES E INSTALANDO GIT
#-------------------------------------------------
echo "=== [1/7] Atualizando lista de pacotes ==="
sudo apt-get update -y

echo "=== [1/7] Instalando Git ==="
sudo apt-get install -y git

echo "=== [1/7] Verificando versão do Git ==="
git --version


#-------------------------------------------------
# 2. INSTALANDO PYTHON 3.8
#-------------------------------------------------
echo "=== [2/7] Instalando pré-requisitos do Python ==="
sudo apt-get install -y software-properties-common

echo "=== [2/7] Adicionando repositório PPA deadsnakes ==="
sudo add-apt-repository ppa:deadsnakes/ppa -y

echo "=== [2/7] Atualizando lista de pacotes novamente ==="
sudo apt-get update -y

echo "=== [2/7] Instalando Python 3.8, venv e distutils ==="
sudo apt-get install -y python3.8 python3.8-venv python3.8-distutils

echo "=== [2/7] Verificando versão do Python 3.8 ==="
python3.8 --version


#-------------------------------------------------
# 3. INSTALANDO TERRAFORM
#-------------------------------------------------
echo "=== [3/7] Instalando dependências para o Terraform ==="
sudo apt-get install -y gnupg curl

echo "=== [3/7] Adicionando chave GPG da HashiCorp ==="
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "=== [3/7] Adicionando repositório oficial da HashiCorp ==="
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "=== [3/7] Atualizando lista de pacotes para o Terraform ==="
sudo apt-get update -y

echo "=== [3/7] Instalando Terraform ==="
sudo apt-get install terraform -y

echo "=== [3/7] Verificando versão do Terraform ==="
terraform -version


#-------------------------------------------------
# 4. INSTALANDO DOCKER E DOCKER COMPOSE
#-------------------------------------------------
echo "=== [4/7] Instalando Docker ==="
sudo apt-get install -y docker.io

echo "=== [4/7] Criando grupo docker (se não existir) ==="
if ! getent group docker >/dev/null; then
  sudo groupadd docker
fi

echo "=== [4/7] Adicionando usuário $USER ao grupo docker ==="
sudo usermod -aG docker $USER

echo "=== [4/7] Instalando Docker Compose ==="
sudo apt-get install -y docker-compose

echo "=== [4/7] Docker e Docker Compose instalados. Lembre-se de sair e entrar novamente na sessão para aplicar as permissões do grupo. ==="


#-------------------------------------------------
# 5. INSTALANDO KUBECTL (v1.33.3)
#-------------------------------------------------
KUBECTL_VERSION="1.33.3"
KUBECTL_DATE="2025-08-03"
KUBECTL_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/${KUBECTL_DATE}/bin/linux/amd64"

echo "=== [5/7] Baixando kubectl v${KUBECTL_VERSION} ==="
curl -LO "${KUBECTL_URL}/kubectl"

echo "=== [5/7] Baixando checksum SHA-256 ==="
curl -LO "${KUBECTL_URL}/kubectl.sha256"

echo "=== [5/7] Verificando integridade do arquivo ==="
sha256sum -c kubectl.sha256

echo "=== [5/7] Tornando o kubectl executável ==="
chmod +x ./kubectl

echo "=== [5/7] Instalando kubectl em \$HOME/bin ==="
mkdir -p $HOME/bin
cp ./kubectl $HOME/bin/kubectl
export PATH=$HOME/bin:$PATH

# Adiciona o caminho ao .bashrc para persistir entre as sessões
if ! grep -q 'export PATH=\$HOME/bin:\$PATH' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Adiciona kubectl ao PATH' >> ~/.bashrc
  echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
fi

echo "=== [5/7] Instalação do kubectl concluída. Execute 'source ~/.bashrc' ou reinicie o terminal. ==="


#-------------------------------------------------
# 6. INSTALANDO HELM (v4.0.0-alpha.1)
#-------------------------------------------------
echo "=== [6/7] Baixando Helm v4.0.0-alpha.1 ==="
wget https://get.helm.sh/helm-v4.0.0-alpha.1-linux-amd64.tar.gz

echo "=== [6/7] Extraindo arquivo do Helm ==="
tar -zxvf helm-v4.0.0-alpha.1-linux-amd64.tar.gz

echo "=== [6/7] Movendo Helm para o diretório de binários ==="
sudo mv linux-amd64/helm /usr/local/bin/helm

echo "=== [6/7] Helm instalado com sucesso! ==="


#-------------------------------------------------
# 7. CONFIGURANDO IAM OIDC PROVIDER PARA EKS
#-------------------------------------------------
cluster_name="desafio"

echo "=== [7/7] Verificando e associando o OIDC provider para o cluster EKS '$cluster_name' (requer AWS CLI configurada) ==="
# Este passo assume que a AWS CLI já está instalada e configurada
if command -v aws &> /dev/null && command -v eksctl &> /dev/null; then
    echo "=== Buscando OIDC ID do cluster $cluster_name ==="
    oidc_id=$(aws eks describe-cluster \
      --name "$cluster_name" \
      --query "cluster.identity.oidc.issuer" \
      --output text | cut -d '/' -f 5 || echo "")

    if [ -n "$oidc_id" ]; then
        echo "OIDC ID: $oidc_id"
        echo "=== Conferindo se já existe OIDC provider associado ==="
        aws iam list-open-id-connect-providers | grep "$oidc_id" | cut -d "/" -f4 || \
        (echo "=== Associando OIDC provider ao cluster ===" && eksctl utils associate-iam-oidc-provider --cluster "$cluster_name" --approve)
    else
        echo "AVISO: Não foi possível obter o OIDC ID do cluster EKS '$cluster_name'. Pule esta etapa."
    fi
else
    echo "AVISO: AWS CLI ou eksctl não encontrados. A associação do OIDC provider para o EKS foi pulada."
fi


echo "================================================="
echo "=== SCRIPT DE INSTALAÇÃO FINALIZADO ==="
echo "================================================="
echo "LEMBRE-SE: Saia e entre novamente na sua sessão de terminal para que todas as alterações, especialmente as permissões do grupo Docker e o PATH do kubectl, tenham efeito."
echo "================================================="