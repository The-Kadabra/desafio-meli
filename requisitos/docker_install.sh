sudo apt install docker.io
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

sudo apt install docker-compose
sudo usermod -aG docker $USER
