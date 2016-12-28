Multi-Node Kubernetes Installation with existing CoreOS
=======================================================

It can be useful to install Kubernetes to the existing CoreOS servers.

# Install Prerequisites

## CoreOS servers

Start CoreOS server with Public and Private IP.

## kubectl

``kubectl`` is the main program for interacting with the Kubernetes API. Download ``kubectl`` from the Kubernetes release artifact site with the ``curl`` tool.
The linux ``kubectl`` binary can be fetched with a command like:

```sh
$ curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/linux/amd64/kubectl
```

On an OS X workstation, replace ``linux`` in the URL above with ``darwin``:

```sh
$ curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/darwin/amd64/kubectl
```

After downloading the binary, ensure it is executable and move it into your PATH:

```sh
$ chmod +x kubectl
$ mv kubectl /usr/local/bin/kubectl
```

# Clone the Repository

```sh
$ git clone https://github.com/TakiTake/coreos-kubernetes
$ cd coreos-kubernetes/multi-node/vps
```

## Set Cluster Info

The supported way to provide Cluster Info to install script is by exporting the following environment variables:

### Mandatry

```sh
ETCD_PUBLIC_IPS
ETCD_PRIVATE_IPS
CONTROLLER_PUBLIC_IPS
CONTROLLER_PRIVATE_IPS
WORKER_PUBLIC_IPS
WORKER_PRIVATE_IPS
```

### Optional

Default username is ``core`` and use ``~/.ssh/id_rsa`` as a identity file:

```sh
SSH_USER=core
SSH_IDENTITY_FILE=~/.ssh/id_rsa
```

# Install Kubernetes to the VPS instances

```sh
$ install.sh
```

# Configure kubectl

## Update the local-user kubeconfig

Configure your local Kubernetes client using the following commands:

```sh
# set first server of controller as a server of cluster
$ kubectl config set-cluster vps-multi-cluster --server=https://$(echo $CONTROLLER_PUBLIC_IPS | cut -d, -f1):443 --certificate-authority=${PWD}/ssl/ca.pem
$ kubectl config set-credentials vps-multi-admin --certificate-authority=${PWD}/ssl/ca.pem --client-key=${PWD}/ssl/admin-key.pem --client-certificate=${PWD}/ssl/admin.pem
$ kubectl config set-context vps-multi --cluster=vps-multi-cluster --user=vps-multi-admin
$ kubectl config use-context vps-multi
```
