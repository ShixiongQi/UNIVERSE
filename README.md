## Starting up an experiment on Cloudlab
1. When starting a new experiment on Cloudlab, select the **small-lan** profile
2. In the profile parameterization page, 
        - Set **Number of Nodes** as **2**
        - Set OS image as **Ubuntu 20.04**
        - Set physical node type, such as **xl170**
        - Please check **Temp Filesystem Max Space**
        - Keep **Temporary Filesystem Mount Point** as default (**/mydata**)

## Extend the disk
On the master node and worker nodes, run
```
sudo chown -R $(id -u):$(id -g) /mydata
cd /mydata
git clone https://github.com/ShixiongQi/UNIVERSE.git
cd /mydata/UNIVERSE
git checkout kube-v1.24-ubuntu-20
export MYMOUNT=/mydata
```

## Deploy Kubernetes Cluster
1. Run `./100-docker_install.sh` without *sudo* on both *master* node and *worker* node
2. Run `source ~/.bashrc`
3. On *master* node, run `./200-k8s_install.sh master <master node IP address>`
4. On *worker* node, run `./200-k8s_install.sh worker` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*

```
sudo kubeadm join 10.10.1.1:6443 --token btytkp.7nh8pawcdsi23g4x \
	--discovery-token-ca-cert-hash sha256:9d1802d5451e559b5c076db6901865b164bd201ed46ce38c1cba03e89618e027 
```

6. run `echo 'source <(kubectl completion bash)' >>~/.bashrc && source ~/.bashrc`

## Install Knative
```
./400-kn-install.sh
```
