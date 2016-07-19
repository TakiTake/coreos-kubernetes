#!/bin/bash -e

SCRIPT_DIR=$(dirname $0)
ETC_DIR="${SCRIPT_DIR}/etc"
ETCD_DIR="${SCRIPT_DIR}/etcd"
CONTROLLER_DIR="${SCRIPT_DIR}/controller"
WORKER_DIR="${SCRIPT_DIR}/worker"
SSL_DIR="${SCRIPT_DIR}/ssl"
INIT_SSL_CA="${SCRIPT_DIR}/../../lib/init-ssl-ca"
INIT_SSL="${SCRIPT_DIR}/../../lib/init-ssl"
CONTROLLER_CLOUD_CONFIG_PATH="${SCRIPT_DIR}/../generic/controller-install.sh"
WORKER_CLOUD_CONFIG_PATH="${SCRIPT_DIR}/../generic/worker-install.sh"

SSH_IDENTITY_FILE=${SSH_IDENTITY_FILE:-~/.ssh/id_rsa}
SSH_USER=${SSH_USER:-core}

# defined in multi-node/generic/controller-install.sh
K8S_SERVICE_IP=10.3.0.1
CONTROLLER_PRIVATE_IPS="${CONTROLLER_PRIVATE_IPS},${K8S_SERVICE_IP}"

mkdir -p $ETC_DIR
mkdir -p $SSL_DIR

function generateEnvironmentFile {
  cat << EOF > "${ETC_DIR}/environment"
ETCD_PUBLIC_IPS=$ETCD_PUBLIC_IPS
ETCD_PRIVATE_IPS=$ETCD_PRIVATE_IPS
CONTROLLER_PUBLIC_IPS=$CONTROLLER_PUBLIC_IPS
CONTROLLER_PRIVATE_IPS=$CONTROLLER_PRIVATE_IPS
WORKER_PUBLIC_IPS=$WORKER_PUBLIC_IPS
WORKER_PRIVATE_IPS=$WORKER_PRIVATE_IPS
EOF
}

function generateAdminKeyCert {
  # Generate root CA
  $INIT_SSL_CA $SSL_DIR

  # Generate admin key/cert
  $INIT_SSL $SSL_DIR admin kube-admin
}

function configEtcd {
  local etcdPublicIPs=(${ETCD_PUBLIC_IPS//,/ })

  for i in "${!etcdPublicIPs[@]}"; do
    scp -i $SSH_IDENTITY_FILE -r $ETC_DIR  "${SSH_USER}@${etcdPublicIPs[$i]}:/tmp"
    scp -i $SSH_IDENTITY_FILE -r $ETCD_DIR "${SSH_USER}@${etcdPublicIPs[$i]}:/tmp"
    ssh -i $SSH_IDENTITY_FILE -l $SSH_USER ${etcdPublicIPs[$i]} /bin/bash /tmp/etcd/config.sh
    ssh -i $SSH_IDENTITY_FILE -l $SSH_USER ${etcdPublicIPs[$i]} sudo coreos-cloudinit --from-file /usr/share/oem/cloud-config.yml
  done
}

function configController {
  local controllerPublicIPs=(${CONTROLLER_PUBLIC_IPS//,/ })
  local controllerPrivateIPs=(${CONTROLLER_PRIVATE_IPS//,/ })
  local cn

  for i in "${!controllerPublicIPs[@]}"; do
    cn="kube-apiserver-${controllerPrivateIPs[$i]}"
    generateMachineSSL 'apiserver' $cn $CONTROLLER_PRIVATE_IPS

    scp -i $SSH_IDENTITY_FILE -r $ETC_DIR                        "${SSH_USER}@${controllerPublicIPs[$i]}:/tmp"
    scp -i $SSH_IDENTITY_FILE -r $CONTROLLER_DIR                 "${SSH_USER}@${controllerPublicIPs[$i]}:/tmp"
    scp -i $SSH_IDENTITY_FILE    ${CONTROLLER_CLOUD_CONFIG_PATH} "${SSH_USER}@${controllerPublicIPs[$i]}:/tmp/controller/install.sh"
    scp -i $SSH_IDENTITY_FILE    "${SSL_DIR}/${cn}.tar"          "${SSH_USER}@${controllerPublicIPs[$i]}:/tmp/ssl.tar"
    ssh -i $SSH_IDENTITY_FILE -l $SSH_USER "${controllerPublicIPs[$i]}" /bin/bash /tmp/controller/config.sh
  done
}

function configWorker {
  local workerPublicIPs=(${WORKER_PUBLIC_IPS//,/ })
  local workerPrivateIPs=(${WORKER_PRIVATE_IPS//,/ })
  local cn

  for i in "${!workerPublicIPs[@]}"; do
    cn="kube-worker-${workerPrivateIPs[$i]}"
    generateMachineSSL 'worker' $cn ${workerPrivateIPs[$i]}

    scp -i $SSH_IDENTITY_FILE -r $ETC_DIR                    "${SSH_USER}@${workerPublicIPs[$i]}:/tmp"
    scp -i $SSH_IDENTITY_FILE -r $WORKER_DIR                 "${SSH_USER}@${workerPublicIPs[$i]}:/tmp"
    scp -i $SSH_IDENTITY_FILE    ${WORKER_CLOUD_CONFIG_PATH} "${SSH_USER}@${workerPublicIPs[$i]}:/tmp/worker/install.sh"
    scp -i $SSH_IDENTITY_FILE    "${SSL_DIR}/${cn}.tar"      "${SSH_USER}@${workerPublicIPs[$i]}:/tmp/ssl.tar"
    ssh -i $SSH_IDENTITY_FILE -l $SSH_USER "${workerPublicIPs[$i]}" /bin/bash /tmp/worker/config.sh
  done
}

# generate SSL key
function generateMachineSSL {
  local certBaseName=$1
  local cn=$2
  local ipAddrs=$3

  $INIT_SSL $SSL_DIR $certBaseName $cn $(ipString $ipAddrs)
}

# IP Array => "IP.1=127.0.0.1,IP.2=10.0.0.1"
function ipString {
  local ipAddrs=(${1//,/ })
  local ips=()

  for i in "${!ipAddrs[@]}"; do
    ips[$i]="IP.$((i+1))=${ipAddrs[$i]}"
  done

  join , "${ips[@]}"
}

# Array => STR
function join {
  local IFS="$1"
  shift
  echo "$*"
}

# Main
generateEnvironmentFile
generateAdminKeyCert
configEtcd
configController
configWorker
