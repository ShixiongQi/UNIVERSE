## Starting up a 11-node cluster on Cloudlab
1. When starting a new experiment on Cloudlab, select the **small-lan** profile
2. In the profile parameterization page, 
        - Set **Number of Nodes** as **11**
        - Set OS image as **Ubuntu 18.04**
        - Set physical node type as **c220g2**
        - Please check **Temp Filesystem Max Space**
        - Keep **Temporary Filesystem Mount Point** as default (**/mydata**)
3. We use `node-0` as master node. `node-1` to `node-10` are used as worker node.

## Extend the disk
On the master node and worker nodes, run
```bash
sudo chown -R $(id -u):$(id -g) <mount point(to be used as extra storage)>
cd <mount point>
git clone https://github.com/ShixiongQi/pod-startup.git
cd <mount point>/pod-startup
git checkout mu-serverless
```
Then run `export MYMOUNT=<mount point>` with the added storage mount point name

- if your **Temporary Filesystem Mount Point** is as default (**/mydata**), please run
```
sudo chown -R $(id -u):$(id -g) /mydata
cd /mydata
git clone https://github.com/ShixiongQi/pod-startup.git
cd /mydata/pod-startup
git checkout mu-serverless
export MYMOUNT=/mydata
```

## Deploy Kubernetes Cluster
1. Run `./docker_install.sh` without *sudo* on both *master* node and *worker* node
2. Run `source ~/.bashrc`
3. Run `./git_clone.sh` to clone the Kubernetes repos.
4. On *master* node, run `./k8s_insatll.sh master <master node IP address>`
5. On *worker* node, run `./k8s_install.sh slave` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*

## Deploy Istio (quick setup)
1. If the system login name is different from the docker name then, run `export DOCKER_USER=<docker name>`
2. On master node, run `./prerequisite.sh`
3. On master node, run `sudo docker login` to login with your dockerhub account
4. On master node, run `${MYMOUNT}/istio/out/linux_amd64/istioctl manifest install -f istio-de.yaml` to setup custom istio
**NOTE: we use the built-up image in Viyom's docker registery directly**
5. **Edit the resource usage of `istio-ingressgateway` deployment. Set CPU as 16 and memory as 40Gi.**

## Deploy Istio (Build manually)
1. If the system login name is different from the docker name then, run `export DOCKER_USER=<docker name>`
2. On master node, run `./prerequisite.sh`
3. On master node, run `sudo docker login` to login with your dockerhub account
4. On master node run `./build_istio.sh` without `sudo`.
5. On master node, hardcode the dockerhub account in istio-de.yaml and then run `${MYMOUNT}/istio/out/linux_amd64/istioctl manifest install -f istio-de.yaml` to setup custom istio or run `install_custom_istio.sh`

To uninstall, run `${MYMOUNT}/istio/out/linux_amd64/istioctl x uninstall --purge` or run `./uninstall_custom_istio.sh`

## Prerequisite of KNative Serving
1. Apply the Placement Decision CRD definition and API server permission
```
kubectl apply -f placementDecisionCrdDefinition.yaml
kubectl apply -f metric_authority.yaml
```

## Build and Setup Knative
1. If you haven't done the above steps, please complete them before moving to step 2.
2. On master node, run `./ko_install.sh`. Please `source ~/.bashrc` after you run the script.
3. On master node, run `./go_dep_install.sh`
4. On master node, run `sudo docker login` to login to your dockerhub account
5. Change permission of ko
```
sudo chown -R $(id -u):$(id -g) /users/$(id -nu)/.docker
sudo chmod g+rwx "/users/$(id -nu)/.docker" -R
```
6. **Depending on the experiment (MU, RPS or CC), modify the Knative source as instructed in section below.**
7. On master node, run `ko apply -f $GOPATH/src/knative.dev/serving/config/` to build and install knative
To uninstall, run `ko delete -f $GOPATH/src/knative.dev/serving/config/`

## Clean up Knative and Istio
1. The termination of the `knative-serving` ns takes a long time. Please be paitent before the `knative-serving` ns gets terminated.
2. Run `ko delete -f $GOPATH/src/knative.dev/serving/config/` to kill all Knative pods. Waiting before all the KNative pods get killed
3. Run `./uninstall_custom_istio.sh` to uninstall Istio. Waiting before all the Istio pods get killed
4. Run `./build_istio.sh` without `sudo`.
5. Run `install_custom_istio.sh`

## Replace the default controller manager (Running as a standalone process)
#### Tips: if the binary cannot be built in /mydata/kubernetes/, download the customized repository to /users/sqi009/ and then complie again
0. Install golang 1.15.4
```
sudo rm -rf /usr/local/go
wget https://dl.google.com/go/go1.15.4.linux-amd64.tar.gz
sudo tar -C /usr/local -zxvf go1.15.4.linux-amd64.tar.gz
```
1. Compiling the customized controller manager
```
cd kubernetes/
make WHAT=cmd/kube-controller-manager KUBE_BUILD_PLATFORMS=linux/amd64
```
2. Terminate the *kube-controller-manager* Pod
```
sudo vim /etc/kubernetes/manifests/kube-controller-manager.yaml
# Change `image: k8s.gcr.io/kube-controller-manager:v1.19.8` to `#image: shixiongqi/customized-kube-controller-manager:v1.1`.
# `customized-kube-controller-manager:v1.1` will crash which is an alternative way to terminate the `kube-controller-manager` Pod, although this is not the perfect method
# Save the changes to the default manifest
# Check whether the pod crashes. If not, try to scale the deployment, so it will crash
```
3. Execute the binary file of **kube-controller-manager**
```
sudo ./_output/bin/kube-controller-manager --kubeconfig=/etc/kubernetes/admin.conf
```

## Experiment Setup: MU, RPS, CC
### Install loadtest
1. Clone loadtest in mu-serverless.
2. Move to loadtest directory.
3. Instasll loadtest dependencies
```
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install -y nodejs
npm install stdio
npm install log
npm install testing
npm install websocket
npm install confinode
npm install agentkeepalive
npm install https-proxy-agent
```
4. Loadtest command for experiment-1 and experiment-2
```
node sample/knative-variable-rps1.js > Workload1LOG & node sample/knative-variable-rps2.js > Workload2LOG &
```

### MU
1. **Modify the service YAML file:** Change CPU/Mem usage if necessary. Change autoscaling policy to `custom2`. Check SLO value, target value, etc.
2. Make sure you are using `socc-exp-yaml-metrics` branch in Knative. Otherwise, do `git checkout socc-exp-yaml-metrics`
3. Experiment preparation:
        - Re-build Knative if any changes has been made: `ko apply -f config/`
        - Apply service YAML: `kubectl apply -f service.yaml`
        - Swtich to customized kube-controller-manager
        - Start VLOG in autoscaler
        - Rename loadtest log if needed

### RPS/CC
1. **Modify the service YAML file:** Change CPU/Mem usage if necessary. Change autoscaling policy to `rps` or `concurrency`. Check SLO value, target value, etc.
2. Make sure you are using `e1bd60b2e8cae46dec00d939c1860deb4b5f586c` branch in Knative. Otherwise, do `git checkout e1bd60b2e8cae46dec00d939c1860deb4b5f586c`
3. Do `git apply defaultChanges.go` after checkout to `e1bd60b2e8cae46dec00d939c1860deb4b5f586c`
4. Experiment preparation:
        - Re-build Knative if any changes has been made: `ko apply -f config/`
        - Apply service YAML: `kubectl apply -f service.yaml`
        - Swtich to default kube-controller-manager
        - Start VLOG in autoscaler
        - Rename loadtest log if needed

<!-- ## Replace the default controller manager (Running as a static Pod)
1. Compiling the customized controller manager
```
cd kubernetes/
sudo ./build/run.sh make WHAT=cmd/kube-controller-manager KUBE_BUILD_PLATFORMS=linux/amd64
```
2. Package the kube-controller-manager binary into a container image. Save the Dockerfile in the Kubernetes directory (`kubernetes/`). See <https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/>
```
FROM busybox
ADD ./_output/dockerized/bin/linux/amd64/kube-controller-manager /usr/local/bin/kube-controller-manager
```
3. Login to the docker hub before continuing. If you already loged in, skip to next step
```
sudo docker login
# Enter your username and password
```
4. Build the image and push it to the docker registry. **Run the following commmands in the directory of the Dockerfile. A version tag need to be specified before building the image**
```
docker build -f $DOCKERFILE -t customized-kube-controller-manager:$VERSION .
docker tag customized-kube-controller-manager:$VERSION shixiongqi/customized-kube-controller-manager:$VERSION
docker push shixiongqi/customized-kube-controller-manager:$VERSION
```
5. Modify the image registry in the default kube-controller-manager manifest
```
sudo vim /etc/kubernetes/manifests/kube-controller-manager.yaml
# Change `image: k8s.gcr.io/kube-controller-manager:v1.19.8` to `#image: shixiongqi/customized-kube-controller-manager:$VERSION`. Specify the version tag of the latest built
# Save the changes to the default manifest

# Replace the default kube-controller-manager
sudo kubectl replace -f /etc/kubernetes/manifests/kube-controller-manager.yaml

# Check if the replacement is success by 'kubectl describe pod $KUBE_CONTROLLER_MANAGER_POD -n kube-system' and creating a new user Pod
```
6. Printout the logs in the kube-controller-manager
```
kubectl logs $KUBE_CONTROLLER_MANAGER_POD -n kube-system
``` -->
