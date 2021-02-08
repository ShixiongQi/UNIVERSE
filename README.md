# Starting up a 2-node cluster on Cloudlab 
1. When starting a new experiment on Cloudlab, select the **small-lan** profile
2. In the profile parameterization page, 
        - Set **Number of Nodes** as **2**
        - Set OS image as **Ubuntu 18.04**
        - Set physical node type as **xl170**
        - Please check **Temp Filesystem Max Space**
        - Keep **Temporary Filesystem Mount Point** as default (**/mydata**)

# Extend the disk
On the master node and worker nodes, run
```bash
sudo chown -R $(id -u):$(id -g) <mount point(to be used as extra storage)>
cd <mount point>
git clone https://github.com/ShixiongQi/pod-startup.git
cd <mount point>/pod-startup
```
Then run `export MYMOUNT=<mount point>` with the added storage mount point name

- if your **Temporary Filesystem Mount Point** is as default (**/mydata**), please run
```
sudo chown -R $(id -u):$(id -g) /mydata
cd /mydata
git clone https://github.com/ShixiongQi/pod-startup.git
cd /mydata/pod-startup
export MYMOUNT=/mydata
```

# Deploy Kubernetes Cluster
1. Run `./docker_install.sh` without *sudo* on both *master* node and *worker* node
2. Run `source ~/.bashrc`
3. Run `./git_clone.sh` to clone the Kubernetes repos.
4. On *master* node, run `./k8s_insatll.sh master <master node IP address>`
5. On *worker* node, run `./k8s_install.sh slave` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*

# Replace the kubelet
1. Before compiling the kubelet, install **Go**: 
```bash
sudo apt update
sudo apt install golang-go
```
2. Compile the kubelet: `build/run.sh make kubelet KUBE_BUILD_PLATFORMS=linux/amd64`
3. Kill and replace the old kubelet
```bash
sudo kill -9 $(pgrep kubelet)
sudo cp _output/dockerized/bin/linux/amd64/kubelet /usr/bin/kubelet
```

## Create an example Pod
kubectl create -f example.yaml

## Container Runtime Creation Time Analysis
1. Print out the log from **kubelet**
`sudo journalctl -u kubelet | grep $(PRINT_OUT_THE_LOG_YOU_SET_IN_THE_SOURCE_CODE) > ~/mylog`
2. `sed -i -r 's/.*SQI009_TRACEPOINT//' ~/mylog`
3. `cat ~/mylog | grep web`

### Major source of the container runtime creation
- create Pod sandbox (0.8s)
- create the user container (1.3s)
- Pull the image from the network (depend on the image size)

## If you want to add the log tracepoints...
klog.Infof("SQI009 time: %+v for pod %q", metav1.Now().String(), format.Pod(pod))

# Replace the default scheduler
TODO
