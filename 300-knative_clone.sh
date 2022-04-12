
#!/bin/bash
mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
	echo MYMOUNT env var not defined
	exit 1
fi

pushd $mount_path

mkdir -p ${GOPATH}/src/knative.dev
pushd ${GOPATH}/src/knative.dev
SERVING_FILE_NAME=serving
git clone --single-branch https://github.com/knative/serving.git ${SERVING_FILE_NAME}
pushd ${SERVING_FILE_NAME}
git checkout tags/v0.22.0

# return to script dir
popd
