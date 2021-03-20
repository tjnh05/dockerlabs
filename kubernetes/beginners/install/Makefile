KUBEVER=1.20.5-00
ifndef KUBEVER
override KUBELET=kubelet
override KUBEADM=kubeadm
override KUBECTL=kubectl
else
KUBELET="kubelet=$(KUBEVER)"
KUBEADM="kubeadm=$(KUBEVER)"
KUBECTL="kubectl=$(KUBEVER)"
endif

define DOCKER_CONFIG 
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
endef
export DOCKER_CONFIG

define DOCKER_PROXY
[Service]
    Environment="HTTP_PROXY=http://172.16.2.15:8080/" "HTTPS_PROXY=http://172.16.2.15:8080/" "NO_PROXY=localhost,127.0.0.0/24,10.0.0.0/8,10.0.0.0/8,192.168.0.0/16,172.0.0.0/8,.deloittecloud.com"
endef
export DOCKER_PROXY

define K8SCONF
net.bridge.bridge-nf-call-iptables = 1
endef
export K8SCONF


POD_NETWORK_CIDR=172.35.0.0/16


prepare:
	sudo apt-get update
	sudo apt-get install -y apt-transport-https curl
	sudo apt-get install -y net-tools tcpdump nmap sysstat
	# Add the Kubernetes repository
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	@echo -n "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
	@echo
docker:
	@sh -x install-docker.sh
	# Install Docker CE
	## Set up the repository:
	### Install packages to allow apt to use a repository over HTTPS
	sudo apt-get update
	sudo apt-get install apt-transport-https ca-certificates \
		curl software-properties-common -y
	### Add Docker official GPG key
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
	echo "$$DOCKER_CONFIG" | sudo tee /etc/docker/daemon.json
	sudo mkdir -p /etc/systemd/system/docker.service.d
	echo "$$DOCKER_PROXY" | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
	# Restart docker.
	sudo systemctl daemon-reload
	sudo systemctl restart docker
	sudo usermod -aG docker $USER 
	sudo newgrp docker


kube:
	sudo apt-get update
	sudo apt-get install -y $(KUBELET) $(KUBEADM) $(KUBECTL)
	echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
	echo "$$K8SCONF" | sudo tee /etc/sysctl.d/k8s.conf
	sudo sysctl --system

calicoctl:
	sudo curl -LO  https://github.com/projectcalico/calicoctl/releases/download/v3.18.1/calicoctl
	sudo install -o root -g root -m 0755 calicoctl /usr/local/bin/calicoctl

kubeinit:
	sudo kubeadm init --pod-network-cidr=$(POD_NETWORK_CIDR)
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

calico:
	curl -LO https://docs.projectcalico.org/manifests/calico.yaml
	sudo kubectl apply -f calico.yaml

cleanup:
	sudo kubeadm reset reset cleanup-node
	sudo rm -rf /etc/cni/net.d
	sudo iptables -F
