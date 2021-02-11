#!/bin/bash

DOCKERFILE=$1
VERSION=$2

docker build -f $DOCKERFILE -t kube-scheduler-with-tracepoints:$VERSION .
docker tag kube-scheduler-with-tracepoints:$VERSION shixiongqi/kube-scheduler-with-tracepoints:$VERSION
docker push shixiongqi/kube-scheduler-with-tracepoints:$VERSION

if [ $? -eq 0 ]; then
	echo "push Success"
else 
	echo "push failed"
fi