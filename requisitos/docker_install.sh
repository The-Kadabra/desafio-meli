#!/bin/bash
set -e

echo "=== Instalando Docker ==="
sudo apt update -y
sudo apt install -y docker.io

echo "=== Criando grupo docker (se não existir) ==="
if ! getent group docker >/dev/null; then
  sudo groupadd docker
fi

echo "=== Adicionando usuário $USER ao grupo docker ==="
sudo usermod -aG docker $USER

echo "=== Recarregando grupos ==="
newgrp docker <<EONG
echo "Grupo docker aplicado para $USER"
EONG

echo "=== Instalando Docker Compose ==="
sudo apt install -y docker-compose

echo "=== Finalizado! Saia e entre novamente na sessão para garantir que as permissões do grupo funcionem. ==="
