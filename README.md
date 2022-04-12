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
git checkout mu-share
export MYMOUNT=/mydata
```

## Deploy a Kubernetes Cluster on Cloudlab
1. Run `./100-docker_install.sh` without *sudo* on both *master* node and *worker* node
2. Run `source ~/.bashrc`
3. On *master* node, run `./200-k8s_install.sh master <master node IP address>`
4. On *worker* node, run `./200-k8s_install.sh slave` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*
5. run `echo 'source <(kubectl completion bash)' >>~/.bashrc && source ~/.bashrc`
6. Enable pod placement on master node and taint worker node:
```
kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl label nodes <master-node-name> location=master
kubectl label nodes <slave-node-name> location=slave

kubectl taint nodes <slave-node-name> location=slave:NoSchedule
```

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
## Please replace "shixiongqi" with your own docker account user ID. if you don't have one, please register one for free -> https://hub.docker.com/ ##
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

<!-- 
## For AFXDP only
1. BCC installation (For Ubuntu 20.04 Focal only): https://github.com/iovisor/bcc/blob/master/INSTALL.md#ubuntu---source
```
# Install dependencies
sudo apt install -y bison build-essential cmake flex git libedit-dev \
  libllvm7 llvm-7-dev libclang-7-dev python zlib1g-dev libelf-dev libfl-dev python3-distutils python3-pip

# compile bcc
git clone https://github.com/iovisor/bcc.git
mkdir bcc/build; cd bcc/build
cmake ..
make -j
sudo make install
cmake -DPYTHON_CMD=python3 .. # build python3 binding
pushd src/python/
make
sudo make install
popd

# install pyroute2
pip3 install pyroute2
```

2. mtcp - AFXDP installation
```
# Install dependencies
sudo apt install -y clang llvm libelf-dev libpcap-dev gcc-multilib build-essential \
                    pkgconf libnuma-dev libz-dev libcap-dev cmake

# Install gRPC lib
git clone https://github.com/rpclib/rpclib.git
cd rpclib && mkdir build && cd build
cmake .. && make && sudo make install

# compile mtcp for AFXDP
cd /mydata/
git clone https://github.com/zengziteng/mtcp.git
# Note-1: When executed in docker container, remove sudo in compile_afxdp_support
# Note-2: Check LINE#179 in ./mtcp/src/config.c, make sure ifidx is hacked as 0
# Note-3: Check MAX_CPUS specified by mTCP
cd mtcp && ./compile_afxdp_support
```

3. Download YAML files
```
cd /mydata/
git clone https://gist.github.com/f56db40853965090dd2d6cf723ebd8b3.git 
cp f56db40853965090dd2d6cf723ebd8b3/tc_redirect_bcc.py ./
cp f56db40853965090dd2d6cf723ebd8b3/simple_nginx.yaml ./
cp f56db40853965090dd2d6cf723ebd8b3/kn-afxdp.yaml ./
```

4. Create Knative functions
```
cd /mydata/
# Modify the mount path if needed
kubectl apply -f kn-afxdp.yaml
```

5. Create 2nd veth in Gateway
```
# Host 
sudo ip link add veth_host-1 type veth peer name veth_pod-1 # Create veth pair

POD_NAME=
sudo docker ps | grep ${POD_NAME} # Identify the pod's container id you want to access and run below command as root on host.

container_id=
pid=$(sudo docker inspect -f '{{.State.Pid}}' ${container_id}) # Get pod's container’s PID

sudo mkdir -p /var/run/netns/ # Create netns directory in the host

sudo ln -sfT /proc/$pid/ns/net /var/run/netns/${container_id} # Create the name space softlink

sudo ip netns exec ${container_id} ip a # Run ip netns command to access pod's network name space

sudo ip link set veth_pod-1 netns ${container_id} # Move the pod's veth into the pod

# Executed in the Container/Pod
sudo ip netns exec ${container_id} ip addr add 172.17.0.100/24 dev veth_pod-1 # Configure IP of additional pod's veth

sudo ip netns exec ${container_id} ip link set dev veth_pod-1 up

# run in the Host
sudo ip link set dev veth_host-1 up # Set the host's veth up
sudo ip link set veth_host-1 master docker0 # Attach the host's veth to the Linux docker bridge
```

6. Configure the routes and arp in AFXDP
```
cd /mydata/mtcp/apps/serverless
mkdir config/
touch config/route.conf

###################
ROUTES 1
# Check the subnet of slave and update accordingly, interface id can leave as 0
192.168.XX.0/24 0
###################
```

7. Install libnuma-dev in gateway pod
```
apt update && apt install -y libnuma-dev
```

8. useful tools for debugging inside pods
```
apt update && apt install -y iproute2 ethtool vim iputils-ping
```

## For DPDK only
Follow the instructions in the link blow:
https://github.com/lesliemonis/smm.git

## Replace the default kubelet (not required at this moment)
0. Check golang version (>=1.15.X)
```
go version
```
1. Run `./300-git_clone.sh` to clone the Kubernetes repos.
2. Compiling the customized kubelet
```
cd kubernetes/
make WHAT=cmd/kubelet KUBE_BUILD_PLATFORMS=linux/amd64
```
3. Backup default kubelet
```
sudo cp /usr/bin/kubelet /usr/bin/backup_kubelet 
```
4. Terminate default kubelet and copy custimized kubelet to `/usr/bin/`
```
sudo kill -9 $(pgrep kubelet) && sudo cp _output/bin/kubelet /usr/bin/kubelet
``` -->
