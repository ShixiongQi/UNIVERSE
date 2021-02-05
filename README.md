# Deploy Kubernetes Cluster
Run `./docker_install.sh` without *sudo* on both *master* node and *worker* node;
On *master* node, run `./k8s_insatll.sh master <master node IP address>`
On *worker* node, run `./k8s_install.sh slave` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*

# Before compiling the kubelet
Install Go: 
`sudo apt update`
`sudo apt install golang-go`

# Compile the kubelet
`build/run.sh make kubelet KUBE_BUILD_PLATFORMS=linux/amd64`

# Kill and replace the old kubelet
sudo kill -9 $(pgrep kubelet)
sudo cp _output/dockerized/bin/linux/amd64/kubelet /usr/bin/kubelet

# Create an example Pod
kubectl create -f example.yaml

# Print out the log
sudo journalctl -u kubelet | grep $(PRINT_OUT_THE_LOG_YOU_SET_IN_THE_SOURCE_CODE)

# If you want to add the log tracepoints...
klog.Infof("SQI009 time: %+v for pod %q", metav1.Now().String(), format.Pod(pod))
