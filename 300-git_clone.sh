
#!/bin/bash
mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
	echo MYMOUNT env var not defined
	exit 1
fi

pushd $mount_path

# get Kubernetes
# git clone https://github.com/ShixiongQi/kubernetes.git
# pushd kubernetes
# git checkout shared-memory
# popd

mkdir -p ${GOPATH}/src/knative.dev
pushd ${GOPATH}/src/knative.dev
SERVING_FILE_NAME=serving
git clone https://github.com/ShixiongQi/serving.git ${SERVING_FILE_NAME}
git checkout SPRIGHT
pushd ${SERVING_FILE_NAME}

# return to script dir
popd
