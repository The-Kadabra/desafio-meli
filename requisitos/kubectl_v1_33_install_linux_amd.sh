#!/bin/bash
# Install kubectl for Kubernetes v1.33

# Download kubectl binary
echo "Downloading kubectl v1.33..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.3/2025-08-03/bin/linux/amd64/kubectl

# Download SHA-256 checksum
echo "Downloading SHA-256 checksum..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.3/2025-08-03/bin/linux/amd64/kubectl.sha256

# Verify SHA-256 checksum
echo "Verifying checksum..."
sha256sum -c kubectl.sha256

# Make the binary executable
echo "Making kubectl executable..."
chmod +x ./kubectl

# Copy the binary to a directory in your PATH
echo "Installing kubectl to $HOME/bin..."
mkdir -p $HOME/bin
cp ./kubectl $HOME/bin/kubectl
export PATH=$HOME/bin:$PATH

# Add $HOME/bin to shell startup file so PATH persists
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
echo "kubectl installation completed. Please restart your shell or run 'source ~/.bashrc'."
