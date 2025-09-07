#!/bin/bash
set -e

echo "=== Atualizando lista de pacotes ==="
sudo apt-get update -y

echo "=== Instalando Git ==="
sudo apt-get install -y git

echo "=== Verificando versão instalada ==="
git --version
