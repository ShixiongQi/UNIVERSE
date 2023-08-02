# Creating a multi-node cluster on Cloudlab

1. The following steps require a **bash** environment on Cloudlab. Please configure the default shell in your CloudLab account to be bash. For how to configure bash on Cloudlab, Please refer to the post "Choose your shell": https://www.cloudlab.us/portal-news.php?idx=49

2. When starting a new experiment on Cloudlab, select the **small-lan** profile

3. On the profile parameterization page, 
    - Set **Number of Nodes** as needed
        - We use *node-0* as the master node to run the control plane of Kubernetes, Knative, and Flame.
        - *node-1*, *node-2*, ..., are used as worker nodes to deploy the aggregator pods and trainer pods.
    - Set OS image as **Ubuntu 20.04**
    - Set physical node type as **c220g5** (or any other preferred node type)
    - Please check **Temp Filesystem Max Space** box
    - Keep **Temporary Filesystem Mount Point** as default (**/mydata**)

4. Wait for the cluster to be initialized (It may take 5 to 10 minutes)

---

5. Extend the disk space on allocated master and worker nodes. This is because Cloudlab only allocates a 16GB disk space.
    - We use `/mydata` as the working directory
    - On the master node and worker nodes, run
```bash
sudo chown -R $(id -u):$(id -g) /mydata
cd /mydata
export MYMOUNT=/mydata
```