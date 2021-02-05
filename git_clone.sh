
#!/bin/bash
mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
	echo MYMOUNT env var not defined
	exit 1
fi

pushd $mount_path

# get Istio
git clone https://github.com/ShixiongQi/kubernetes.git
pushd kubernetes
#git checkout 803d66019c79ab9e41850c4e27ef26ed2a82025c
git checkout pod-startup
popd

# return to script dir
popd