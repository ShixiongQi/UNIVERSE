#!/bin/bash

# Clone flame repository 
# Reference: https://github.com/gauravratnakar256/FederatedLearning/tree/master/latestFlame/flame
git clone https://github.com/WidjiWidji/flame.git
cd flame/fiab

# Install Helm
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh 

# Install jq
sudo apt update
sudo apt install -y jq

# Install Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/baremetal/deploy.yaml

# Install Certificate Manager
./setup-cert-manager.sh

# Install haproxy
sudo apt-get install haproxy

export MYMOUNT=/mydata
mount_path=$MYMOUNT
sudo service containerd stop
sudo mv /var/lib/containerd $mount_path
sudo ln -s $mount_path/containerd /var/lib/containerd
sudo service containerd restart

