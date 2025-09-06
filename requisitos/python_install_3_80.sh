# 1. Atualizar pacotes
sudo apt-get update

# 2. Instalar pré-requisitos
sudo apt-get install -y software-properties-common

# 3. Adicionar o repositório deadsnakes (caso não exista no padrão)
sudo add-apt-repository ppa:deadsnakes/ppa -y

# 4. Atualizar lista de pacotes novamente
sudo apt-get update

# 5. Instalar Python 3.8
sudo apt-get install -y python3.8 python3.8-venv python3.8-distutils

# 6. Verificar versão
python3.8 --version
