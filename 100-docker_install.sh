#!/bin/bash
# please hardcode the mount path and run this script with non-root user
# don't forget source ~/.bashrc after running this script
mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
	echo MYMOUNT env var not defined
	exit 1
fi

function move_docker_dir {
        sudo service docker stop
        sudo mv /var/lib/docker $mount_path 
        sudo ln -s $mount_path/docker /var/lib/docker
        sudo service docker restart
        sudo docker -v
}

function move_containerd_dir {
        sudo service containerd stop
        sudo mv /var/lib/containerd $mount_path 
        sudo ln -s $mount_path/containerd /var/lib/containerd
        sudo service containerd restart
        sudo docker -v
}

function set_up_docker_repo {
        # Set up the docker repository for kubernetes-v1.24
        sudo apt-get update
        sudo apt-get install -y \
                ca-certificates \
                curl \
                gnupg \
                lsb-release
        
        # Add Docker’s official GPG key
        sudo mkdir -m 0755 -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Use the following command to set up the repository
        echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

function reset_containerd {
        sudo apt remove -y containerd
        sudo apt update
        sudo apt install -y containerd.io
        sudo rm /etc/containerd/config.toml
        sudo systemctl restart containerd
}

set_up_docker_repo

sudo apt update
sudo apt install -y docker.io
sudo docker run hello-world
sudo docker -v

reset_containerd

# If you install Kubernetes on your own machines that have enough disk space
# You could disable the following two commands
move_containerd_dir
move_docker_dir

# echo "====== please check whether docker is ready ======"
# read varname

sudo apt-get purge golang*
mkdir -p download
cd download
wget https://golang.org/dl/go1.15.6.linux-amd64.tar.gz
tar -xvf go1.15.6.linux-amd64.tar.gz
# remove old go bin files
sudo rm -r /usr/local/go
# add new go bin files
sudo mv go /usr/local

# store the source codes
mkdir -p $mount_path/go

GOROOT=/usr/local/go
GOPATH=$mount_path/go
echo "export GOROOT=/usr/local/go" >> ~/.bashrc
echo "export GOPATH=$mount_path/go" >>  ~/.bashrc
echo "export PATH=$PATH:$GOROOT/bin:$GOPATH/bin"  >>  ~/.bashrc

source ~/.bashrc
echo "please source ~/.bashrc"
