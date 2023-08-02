#!/bin/bash

# Please run this script with non-root user
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

sudo apt update
sudo apt install -y docker.io
sudo docker run hello-world
sudo docker -v
move_docker_dir