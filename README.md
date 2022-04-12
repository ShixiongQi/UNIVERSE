## Starting up an experiment on Cloudlab
**IMPORTANT:** The following steps require a `bash` environment. Please configure the default shell in your CloudLab account to be `bash`. For how to configure `bash` on Cloudlab, Please refer to the post "Choose your shell": https://www.cloudlab.us/portal-news.php?idx=49
1. When starting a new experiment on Cloudlab, select the **small-lan** profile
2. In the profile parameterization page, 
        - Set **Number of Nodes** as **2**  
        - Set OS image as **Ubuntu 20.04**  
        - Set physical node type as **xl170**  
        - Please check **Temp Filesystem Max Space**  
        - Keep **Temporary Filesystem Mount Point** as default (**/mydata**)  
<!-- 3. We use `node-0` as master node. `node-1` to `node-10` are used as worker node. -->

## Extend the disk
On the master node and worker nodes, run
```
sudo chown -R $(id -u):$(id -g) /mydata
cd /mydata
git clone https://github.com/ShixiongQi/UNIVERSE.git
cd /mydata/UNIVERSE
git checkout build-knative
export MYMOUNT=/mydata
```

## Deploy a Kubernetes Cluster on Cloudlab
1. Run `./100-docker_install.sh` without *sudo* on both *master* node and *worker* node
2. Run `source ~/.bashrc`
3. On *master* node, run `./200-k8s_install.sh master <master node IP address>`  
**Note:** To get the IP of the master node, run `ip a` on the master node, using the IP address that starts with 128.XXX.XXX.XXX
4. On *worker* node, run `./200-k8s_install.sh slave` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*
5. On *master* node, run `echo 'source <(kubectl completion bash)' >>~/.bashrc && source ~/.bashrc`
<!-- 6. Enable pod placement on master node and taint worker node:
```
kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl label nodes <master-node-name> location=master
kubectl label nodes <slave-node-name> location=slave

kubectl taint nodes <slave-node-name> location=slave:NoSchedule
``` -->

<!-- ## Install some tools if needed 
```
sudo apt install -y byobu htop apache2-utils
``` -->

<!-- 
```
# For single node deployment
kubectl taint nodes --all node-role.kubernetes.io/master-

# install byobu, htop, ab, perf
sudo apt install -y byobu htop apache2-utils
sudo apt-get install -y linux-tools-common linux-tools-generic linux-tools-`uname -r`

echo 'source <(kubectl completion bash)' >>~/.bashrc
``` -->

## Clone the Knative repository (v0.22.2) (on Master node)
```
./300-knative_clone.sh
```

## Install ko (on Master node)
```
./400-ko-install.sh
```

## Build Knative from source (on Master node)
```
## Please replace "shixiongqi" with your own docker account user ID.  
## If you don't have one, please register one for free -> https://hub.docker.com/ ##
export DOCKER_USER=shixiongqi
echo "export KO_DOCKER_REPO='docker.io/$DOCKER_USER'" >> ~/.bashrc
source ~/.bashrc

sudo docker login
# You need to enter your docker account user ID and password

sudo chown -R $(id -u):$(id -g) /users/$(id -nu)/.docker
sudo chmod g+rwx "/users/$(id -nu)/.docker" -R

cd /mydata/go/src/knative.dev/serving/

ko apply -Rf config/
```

## Start up an example Knative function (on Master node)
```
kubectl apply -f example-knative-function.yaml

# See if the function can be started up successfully
kubectl get pods
```

## Install a networking layer (Istio) (on Master node)
```
# Install a properly configured Istio
kubectl apply -f https://github.com/knative/net-istio/releases/download/v0.22.0/istio.yaml
# Install the Knative Istio controller:
kubectl apply -f https://github.com/knative/net-istio/releases/download/v0.22.0/net-istio.yaml
```

## Send packets to the example function (on Master node)
```
ingressHost=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
ingressPort=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

# Get the name of example Knative function
# example.default.example.com
kubectl get ksvc

# The HTTP request will let the Knative function sleep for 500ms before returning a response
curl -v --trace-time -H "Host: example.default.example.com" http://$ingressHost:$ingressPort?sleep=500
```
