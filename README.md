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
git checkout next
export MYMOUNT=/mydata
```

## Deploy Kubernetes Cluster
1. Run `./100-docker_install.sh` without *sudo* on both *master* node and *worker* node
2. Run `source ~/.bashrc`
3. Run `./101-cri-dockerd_install.sh` without *sudo* on both *master* node and *worker* node
4. On *master* node, run `./200-k8s_install.sh master <master node IP address>`
**Note:** To get the IP of the master node, run `ip a` on the master node, using the IP address that starts with 128.XXX.XXX.XXX
5. On *worker* node, run `./200-k8s_install.sh worker` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*

**IMPORTANT**: add `--cri-socket unix:///var/run/cri-dockerd.sock` at the end of `kubeadm join ...` command before you enter it. Example code snippet:
```
sudo kubeadm join 10.10.1.1:6443 --token btytkp.7nh8pawcdsi23g4x \
	--discovery-token-ca-cert-hash sha256:9d1802d5451e559b5c076db6901865b164bd201ed46ce38c1cba03e89618e027 \
  --cri-socket unix:///var/run/cri-dockerd.sock
```
**Note:** add config from *master* node to *worker* node.
1. On *master* node, copy contents of .kube/config `cat ~/.kube/config`
2. On *worker* node, create ~/.kube/config and paste content 
```
mkdir ~/.kube
sudo vim ~/.kube/config
```

6. run `echo 'source <(kubectl completion bash)' >>~/.bashrc && source ~/.bashrc`

## Install Knative
```
./400-kn-install.sh
```

## Setup Flame (on Worker node)
1. Run `./500-flame-install.sh`
2. Add urls to /etc/hosts using *master* node ip address.
Example
```
128.110.218.153	apiserver.flame.test
128.110.218.153	notifier.flame.test
128.110.218.153	mlflow.flame.test
128.110.218.153	controller.flame.test
```
3. Setup load balancing with haproxy ` sudo vim /etc/haproxy/haproxy.cfg`
Example code snippet (add to end of haproxy.cfg):
```
listen l1
	bind	0.0.0.0:443
	mode	tcp
	timeout	connect	4000
	timeout	client	180000
	timeout	server	180000
	server	srv1	0.0.0.0:32115

listen l2
	bind	0.0.0.0:80
	mode	tcp
	timeout	connect	4000
	timeout	client	180000
	timeout	server	180000
	server	srv2	0.0.0.0:31127
```
**Note:** change srv1 and srv2 using ingress-nginx-controller ports from `kubectl get svc -A` 
4. Restart haproxy `sudo systemctl restart haproxy`

# Start Flame
```
sudo ./flame.sh start
```

