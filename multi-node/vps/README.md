Multi-Node Kubernetes Installation with existing CoreOS
=======================================================

It can be useful to install Kubernetes to existing CoreOS servers.

# Install Prerequisites

## CoreOS servers

Start CoreOS server with Public and Private IP.

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

# Execute install.sh

```sh
$ install.sh
```
