## Kubernetes installation guideline on NSF Cloudlab
We demonstrate the installation of Kubernetes (based on `kubeadm`) on NSF Cloudlab, using a multi-node cluster. This installation guideline has been tested with physical node type `xl170`, `c220g1`, `c220g2`, and `c220g5`, all with `Ubuntu 20.04`.

**Note:** As Cloudlab only allocates 16GB disk space by default, please check *Temp Filesystem Max Space* to maximize the disk space configuration and keep *Temporary Filesystem Mount Point* as default (/mydata)

Follow steps below to set up Kubernetes:

* [Creating a multi-node cluster on Cloudlab](01-create-cluster-on-cloudlab.md)
* [Setting up Kubernetes](02-setup-k8s.md)