
#!/bin/bash
mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
	echo MYMOUNT env var not defined
	exit 1
fi

pushd $mount_path

# get Kubernetes
git clone https://github.com/ShixiongQi/kubernetes.git
pushd kubernetes
git checkout shared-memory
popd

# return to script dir
popd
