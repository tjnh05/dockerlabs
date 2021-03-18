# Install Kubeadm, Kubelet, and Kubectl 
#VERSION=1.18.6-00
VERSION=1.20.0-00
sudo apt-get update 
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION 
# Enable net.bridge.bridge-nf-call-iptables
#echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf 

# Temporarily disable IPv6 address
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

#sudo sysctl -p 
