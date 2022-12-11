#/bin/bash
#this script can be run with non-root user
function usage {
        echo "$0 [master] [master-ip] or [worker]"
        exit 1
}

node_type=$1
master_ip=$2

if [ "$node_type" = "master" -a "$master_ip" = "" ]
then
    usage

elif [ "$node_type" != "master" -a "$node_type" != "worker" ] 
then
    usage
fi

function install_docker_ce {
	sudo apt-get update
	sudo apt-get install -y \
	     apt-transport-https \
	     ca-certificates \
	     curl
}

function off_swap {
	sudo swapoff -a
	cat /etc/fstab | grep -v '^#' | grep -v 'swap' | sudo tee /etc/fstab	
}

function install_k8s_tools {
	sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
	echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

	sudo apt-get update
	sudo apt-get install -y kubelet kubeadm kubectl
	sudo apt-mark hold kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00

	sudo systemctl daemon-reload
	sudo systemctl restart kubelet
}
 
function deploy_k8s_master {
	# deploy kubernetes cluster
 	sudo kubeadm init --apiserver-advertise-address=$master_ip --pod-network-cidr=192.168.0.0/16
	# for non-root user, make sure that kubernetes config directory has the same permissions as kubernetes config file.
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/

	#after this step, coredns status will be changed to running from pending
	kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
	kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
	kubectl get nodes
	kubectl get pods --namespace=kube-system
}

install_docker_ce
off_swap
install_k8s_tools
if [ "$node_type" = "master" ] 
then
    deploy_k8s_master
fi
