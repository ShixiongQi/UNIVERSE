## Starting up an experiment on Cloudlab
1. When starting a new experiment on Cloudlab, select the **small-lan** profile
2. In the profile parameterization page, 
        - Set **Number of Nodes** as **2**
        - Set OS image as **Ubuntu 20.04**
        - Set physical node type as **xl170**
        - Please check **Temp Filesystem Max Space**
        - Keep **Temporary Filesystem Mount Point** as default (**/mydata**)
<!-- 3. We use `node-0` as master node. `node-1` to `node-10` are used as worker node. -->

## Update the kernel of master node to 5.15 (For AFXDP only)
```
# Run apt command one by one
sudo apt update
sudo apt -y upgrade
sudo apt install -y dpkg wget gpg

mkdir kernel_update
cd kernel_update
wget https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
chmod +x ubuntu-mainline-kernel.sh
sudo ./ubuntu-mainline-kernel.sh -i 5.15.11
sudo reboot
```
Fix the broken installation of apt before installing Kubernetes
```
sudo apt --fix-broken install
```

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

## Deploy Kubernetes Cluster
1. Run `./100-docker_install.sh` without *sudo* on both *master* node and *worker* node
2. Run `source ~/.bashrc`
3. On *master* node, run `./200-k8s_insatll.sh master <master node IP address>`
4. On *worker* node, run `./200-k8s_install.sh slave` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*

```
# For single node deployment
kubectl taint nodes --all node-role.kubernetes.io/master-

# install byobu, htop, ab, perf
sudo apt install -y byobu htop apache2-utils
sudo apt-get install -y linux-tools-common linux-tools-generic linux-tools-`uname -r`

echo 'source <(kubectl completion bash)' >>~/.bashrc
```

## Clone the Kubernetes and Knative repository
```
./300-git_clone.sh
```

## Install ko
```
./400-ko-install.sh
```

## Build Knative from source
```
export DOCKER_USER=shixiongqi
echo "export KO_DOCKER_REPO='docker.io/$DOCKER_USER'" >> ~/.bashrc
source ~/.bashrc

sudo docker login

sudo chown -R $(id -u):$(id -g) /users/$(id -nu)/.docker
sudo chmod g+rwx "/users/$(id -nu)/.docker" -R

cd /mydata/go/src/knative.dev/serving/

ko apply -Rf config/
```

## For AFXDP only
1. BCC installation
2. mtcp - AFXDP installation
3. Create 2nd veth in Gateway
4. Configure the routes and arp in AFXDP
5. Download YAML files
6. Create Knative functions

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
```
