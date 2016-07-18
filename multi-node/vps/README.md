Multi-Node Kubernetes Installation with existing CoreOS
=======================================================

It can be useful to install Kubernetes to existing CoreOS servers.

# Install Prerequisites

## CoreOS servers

Start CoreOS server with Public and Private IP.

# Clone the Repository

```sh
$ git clone https://github.com/TakiTake/coreos-kubernetes
$ cd coreos-kubernetes/multi-node/static
```

## Cluster Info

The supported way to provide Cluster Info to install script is by exporting the following environment variables:

### Mandatry

```sh
export ETCD_HOST_IPS=
export ETCD_CLUSTER_IPS=
export CONTROLLER_HOST_IPS=
export CONTROLLER_CLUSTER_IPS=
export WORKER_HOST_IPS=
export WORKER_CLUSTER_IPS=
```

### Optional

```sh
export SSH_USER=core
export SSH_IDENTITY_FILE=~/.ssh/id_rsa
```

# Execute install.sh

```sh
$ install.sh
```
