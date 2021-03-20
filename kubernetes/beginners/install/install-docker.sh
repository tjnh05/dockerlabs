# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
### Add Docker’s official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
### Add Docker apt repository.
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
## Install Docker CE.
#apt-get update && apt-get install docker-ce=18.06.2~ce~3-0~ubuntu
sudo apt-get update && sudo apt-get install docker-ce
# Setup daemon.
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
    Environment="HTTP_PROXY=http://172.16.2.15:8080/" "HTTPS_PROXY=http://172.16.2.15:8080/" "NO_PROXY=localhost,127.0.0.0/24,10.0.0.0/8,10.0.0.0/8,192.168.0.0/16,172.0.0.0/8,.deloittecloud.com"
EOF

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo usermod -aG docker $USER && newgrp docker
