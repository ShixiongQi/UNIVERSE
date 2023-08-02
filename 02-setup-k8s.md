# Setting up Kubernetes & Knative on Cloudlab

## 1 - Download installation script to the working directory
On the master node and worker nodes, run
```bash
cd /mydata && git clone https://github.com/ShixiongQi/UNIVERSE.git
cd /mydata/UNIVERSE/
```

## 2 - Setting up Kubernetes (v1.19.0) master node (**node-0**)
```bash
$ cd /mydata/UNIVERSE/ && export MYMOUNT=/mydata

UNIVERSE$ ./100-docker-install.sh && source ~/.bashrc

UNIVERSE$ ./200-k8s-install.sh master 10.10.1.1 calico

## Once the installation of Kuberentes control plane is done, 
## it will print out an token `kubeadm join ...`. 
## **PLEASE copy and save this token somewhere**. 
## The worker nodes needs this token to join the Kuberentes control plane.

UNIVERSE$ echo 'source <(kubectl completion bash)' >> ~/.bashrc && source ~/.bashrc
```

## 3 - Setting up Kubernetes worker nodes (**node-1**, **node-2**, ...).
```bash
$ cd /mydata/UNIVERSE/ && export MYMOUNT=/mydata

UNIVERSE$ ./100-docker-install.sh && source ~/.bashrc

UNIVERSE$ ./200-k8s-install.sh worker

# Use the token returned from the master node (**node-0**) to join the Kubernetes control plane. Run `sudo kubeadm join ...` with the token just saved. Please run the `kubeadm join` command with *sudo*

UNIVERSE$ sudo kubeadm join <control-plane-token>
```