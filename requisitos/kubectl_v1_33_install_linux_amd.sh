#!/bin/bash
set -e

# Install kubectl for Kubernetes v1.33
KUBECTL_VERSION="1.33.3"
KUBECTL_DATE="2025-08-03"
KUBECTL_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/${KUBECTL_DATE}/bin/linux/amd64"

echo "=== Downloading kubectl v${KUBECTL_VERSION} ==="
curl -LO "${KUBECTL_URL}/kubectl"

echo "=== Downloading SHA-256 checksum ==="
curl -LO "${KUBECTL_URL}/kubectl.sha256"

echo "=== Verifying checksum ==="
sha256sum -c kubectl.sha256

echo "=== Making kubectl executable ==="
chmod +x ./kubectl

echo "=== Installing kubectl to \$HOME/bin ==="
mkdir -p $HOME/bin
cp ./kubectl $HOME/bin/kubectl
export PATH=$HOME/bin:$PATH

# Persist PATH in shell startup file
if ! grep -q 'export PATH=\$HOME/bin:\$PATH' ~/.bashrc; then
  echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
fi

echo "=== kubectl installation completed ==="
echo "Run 'source ~/.bashrc' or restart your shell to update PATH."