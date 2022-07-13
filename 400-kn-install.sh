#!/bin/bash
mount_path=$MYMOUNT

if [[ $mount_path == "" ]]
then
	echo MYMOUNT env var not defined
	exit 1
fi

echo 'Install Knative Serving'
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.5.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.5.0/serving-core.yaml

echo 'Install Istio'
kubectl apply -l knative.dev/crd-install=true -f https://github.com/knative/net-istio/releases/download/knative-v1.5.0/istio.yaml
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.5.0/istio.yaml
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.5.0/net-istio.yaml
kubectl --namespace istio-system get service istio-ingressgateway
