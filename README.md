## Starting up a 2-node cluster on Cloudlab 
1. When starting a new experiment on Cloudlab, select the **small-lan** profile
2. In the profile parameterization page, 
        - Set **Number of Nodes** as **2**
        - Set OS image as **Ubuntu 18.04**
        - Set physical node type as **xl170**
        - Please check **Temp Filesystem Max Space**
        - Keep **Temporary Filesystem Mount Point** as default (**/mydata**)

## Extend the disk
On the master node and worker nodes, run
```bash
sudo chown -R $(id -u):$(id -g) <mount point(to be used as extra storage)>
cd <mount point>
git clone https://github.com/ShixiongQi/UNIVERSE.git
cd <mount point>/UNIVERSE
```
Then run `export MYMOUNT=<mount point>` with the added storage mount point name

- if your **Temporary Filesystem Mount Point** is as default (**/mydata**), please run
```
sudo chown -R $(id -u):$(id -g) /mydata
cd /mydata
git clone https://github.com/ShixiongQi/UNIVERSE.git
cd /mydata/UNIVERSE
git checkout openfaas
export MYMOUNT=/mydata
```

## Deploy Kubernetes Cluster
1. Run `./100-docker_install.sh` without *sudo* on both *master* node and *worker* node
2. Run `source ~/.bashrc`
3. On *master* node, run `./200-k8s_insatll.sh master <master node IP address>`
4. On *worker* node, run `./200-k8s_install.sh slave` and then use the `kubeadm join ...` command obtained at the end of the previous step run in the master node to join the k8s cluster. Run the `kubeadm join` command with *sudo*

## Login docker
```
sudo docker login
```

## Configure the permission of docker
```
sudo chown -R $(id -u):$(id -g) /users/$(id -nu)/.docker
sudo chmod g+rwx "/users/$(id -nu)/.docker" -R
sudo chown -R $(id -u):$(id -g) /var/run/docker.sock
```

## Install OpenFaaS
```
curl -sL https://cli.openfaas.com | sudo sh

curl -SLsf https://dl.get-arkade.dev/ | sudo sh

arkade install openfaas
```

## add docker username to ~/.bashrc
```
echo 'export OPENFAAS_PREFIX="shixiongqi"' >> ~/.bashrc
source ~/.bashrc
```

## Port forward OpenFaaS Gateway
```
kubectl port-forward svc/gateway -n openfaas 8080:8080
```

## Login OpenFaaS
```
export OPENFAAS_URL="http://127.0.0.1:8080"
echo 'export OPENFAAS_URL="http://127.0.0.1:8080"' >> ~/.bashrc 
source ~/.bashrc
PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
echo -n $PASSWORD | faas-cli login --username admin --password-stdin

faas-cli list
```

## Download of-watchdog template
```
faas template pull https://github.com/openfaas-incubator/python-flask-template
# echo 'export OPENFAAS_PREFIX=shixiongqi' >> ~/.bashrc
```

## Create test function
```
export FN="tester"
faas new --lang python3-flask $FN --prefix="shixiongqi"
faas up -f $FN.yml

echo -n content | faas invoke $FN
```
