#!/bin/bash
#please hardcode the mount path, docker hub account and tag.
#you can run this script with non-root user, you'd better login docker hub first
mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
        echo MYMOUNT env var not defined
        exit 1
fi

if [[ $DOCKER_USER == "" ]]
then
	echo DOCKER_USER not defined
	exit 1
fi

if [[ $TAG == "" ]]
then
	echo TAG not defined
	echo use TAG=latest?[Y/n]
	read ans
	if [[ $ans == "n" ]]
	then
		echo "please input TAG name:"
		read tag
		export TAG=$tag
		echo "TAG is $tag"	
	else
		export TAG=latest
	fi
fi

export HUB=docker.io/$DOCKER_USER
#export HUB=docker.io/xiaosu0322
#export TAG=latest
sudo chmod 777 $mount_path
sudo chown -R $(id -u):$(id -g) /users/$(id -nu)/.docker
#sudo chown "$USER":root /users/"$USER"/.docker -R
sudo chmod g+rwx "/users/$(id -nu)/.docker" -R
#sudo chmod g+rwx "/users/$USER/.docker" -R
cd $mount_path 
#git clone --recursive https://github.com/mu-serverless/istio
pushd istio
#git checkout c72e465687b49fa26fefe3d0e6ef32617600ccfa
#git submodule update --recursive --remote
sudo make gen-charts
if [ $? -ne 0 ]; then
    echo "gen-charts for istio failed"
    exit
fi
sudo make build
if [ $? -ne 0 ]; then
    echo "build istio failed"
    exit
fi

popd

#git clone https://github.com/mu-serverless/lb-envoy-wasm.git
#pushd lb-envoy-wasm
#git checkout predictive_jsq
#popd

#git clone https://github.com/istio/proxy.git
#build envoy wasm and envoy
pushd proxy
#git checkout 7879d4f093343ece7c9249c9ee86cf1395fee05e
export TEST_TMPDIR=$mount_path/cache_bazel
make BAZEL_BUILD_ARGS=--override_repository=envoy=$mount_path/lb-envoy-wasm build_wasm
if [ $? -ne 0 ]; then
    echo "build envoy wasm failed"
    exit
fi
popd
# replace wasm files (copy and modify the names)
sudo cp $mount_path/proxy/bazel-bin/extensions/*.wasm $mount_path/istio/out/linux_amd64/release/
pushd $mount_path/istio/out/linux_amd64/release/
sudo mv metadata_exchange.compiled.wasm metadata-exchange-filter.compiled.wasm
sudo mv metadata_exchange.wasm metadata-exchange-filter.wasm
sudo mv stats.compiled.wasm stats-filter.compiled.wasm
sudo mv stats.wasm stats-filter.wasm
popd

pushd proxy
export TEST_TMPDIR=$mount_path/cache_bazel
make BAZEL_BUILD_ARGS=--override_repository=envoy=$mount_path/lb-envoy-wasm
if [ $? -ne 0 ]; then
    echo "build envoy failed"
    exit
fi
popd

#replace envoy binary
pushd $mount_path/istio/out/linux_amd64/release/
sudo cp $mount_path/proxy/bazel-bin/src/envoy/envoy $mount_path/istio/out/linux_amd64/release/
AB=$(ls envoy-*)

sudo cp $mount_path/proxy/bazel-bin/src/envoy/envoy $AB
popd


pushd $mount_path/istio
sudo make docker
if [ $? -ne 0 ]; then
    echo "build istio docker image failed"
    exit
fi

sudo docker login
sudo make push
if [ $? -ne 0 ]; then
    echo "push docker image to docker hub failed"
    exit
fi
popd
