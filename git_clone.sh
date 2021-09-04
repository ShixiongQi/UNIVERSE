
#!/bin/bash
mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
	echo MYMOUNT env var not defined
	exit 1
fi

pushd $mount_path

# get Kubernetes
git clone https://github.com/mu-serverless/kubernetes.git
pushd kubernetes
git checkout socc-exp-yaml-metrics
popd

# get Istio
git clone --recursive https://github.com/mu-serverless/istio
pushd istio
git checkout custom-istio
rm -rf api
git clone https://github.com/mu-serverless/api.git
popd

# get Envoy
git clone https://github.com/mu-serverless/lb-envoy-wasm.git
pushd lb-envoy-wasm
git checkout MinWork 
popd

# get proxy
git clone https://github.com/mu-serverless/proxy-1.git proxy
pushd proxy
git checkout custom-proxy
popd

# get knative-func
git clone https://github.com/mu-serverless/knative-func.git

# get knative-serving
mkdir -p ${GOPATH}/src/knative.dev
pushd ${GOPATH}/src/knative.dev
SERVING_FILE_NAME=serving
git clone https://github.com/mu-serverless/serving_li.git ${SERVING_FILE_NAME}
pushd ${SERVING_FILE_NAME}

git checkout socc-exp-yaml-metrics
popd

# return to script dir
popd
