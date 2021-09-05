#!/bin/bash

mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
	echo MYMOUNT env var not defined
	exit 1
fi

sudo chmod 777 $mount_path
cd ${mount_path}
knative_fun=$mount_path/knative-func
cd ${GOPATH}/src/knative.dev

SERVING_FILE_NAME=serving

cd ${SERVING_FILE_NAME}

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(id -nu)

kubectl apply -f ./third_party/cert-manager-0.12.0/cert-manager-crds.yaml

# Edited config-network.yaml:
cp $knative_fun/knative_install/config-network.yaml ${GOPATH}/src/knative.dev/${SERVING_FILE_NAME}/config/config-network.yaml
echo "====== please check config-network.yaml ======"
read check

sudo docker login
sudo chown -R $(id -u):$(id -g) /users/$(id -nu)/.docker
sudo chmod g+rwx "/users/$(id -nu)/.docker" -R
ko apply -f config/

cd $knative_fun/knative_install_v0_8
chmod +x ./knative_deploy_auto_scaling_rule.sh
./knative_deploy_auto_scaling_rule.sh

echo "====== if you encounter: error: unable to recognize STDIN: no matches for kind Image in version"
echo "====== please re-run ko apply -f config/"
echo " "

echo "====== please verify the metric server exists ======"
read check
cd $knative_fun
kubectl apply -f metric_authority.yaml
sudo ./clean_disk.sh

echo "kubectl -n knative-serving get pods -w"
kubectl -n knative-serving get pods -w
