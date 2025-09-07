#!/bin/bash
set -e

echo "=== 1. Atualizando pacotes ==="
sudo apt-get update -y

echo "=== 2. Instalando pré-requisitos ==="
sudo apt-get install -y software-properties-common

echo "=== 3. Adicionando repositório deadsnakes ==="
sudo add-apt-repository ppa:deadsnakes/ppa -y

echo "=== 4. Atualizando lista de pacotes novamente ==="
sudo apt-get update -y

echo "=== 5. Instalando Python 3.8 ==="
sudo apt-get install -y python3.8 python3.8-venv python3.8-distutils

echo "=== 6. Verificando versão instalada ==="
python3.8 --version
