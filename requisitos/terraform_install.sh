# 1. Atualizar pacotes
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# 2. Adicionar a chave GPG da HashiCorp
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# 3. Adicionar o repositório oficial da HashiCorp
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# 4. Atualizar lista de pacotes
sudo apt-get update

# 5. Instalar o Terraform
sudo apt-get install terraform -y

# 6. Verificar versão instalada
terraform -version
