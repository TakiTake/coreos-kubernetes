#!/bin/bash -e

SCRIPT_DIR=$(dirname $0)
SSH_IDENTITY_FILE=${SSH_IDENTITY_FILE:-~/.ssh/id_rsa}
SSH_USER=${SSH_USER:-core}

cat << EOF > "${SCRIPT_DIR}/etc/environment"
ETCD_HOST_IPS=$ETCD_HOST_IPS
ETCD_CLUSTER_IPS=$ETCD_CLUSTER_IPS
EOF

# generate SSL key

# config etcd
for etcd_host_ip in $(echo $ETCD_HOST_IPS | sed 's/,/ /g'); do
	scp -i $SSH_IDENTITY_FILE -r "${SCRIPT_DIR}/etc" "${SSH_USER}@${etcd_host_ip}:/tmp"
	scp -i $SSH_IDENTITY_FILE -r "${SCRIPT_DIR}/etcd" "${SSH_USER}@${etcd_host_ip}:/tmp"
	ssh -i $SSH_IDENTITY_FILE -l $SSH_USER $etcd_host_ip /bin/bash /tmp/etcd/config.sh
	ssh -i $SSH_IDENTITY_FILE -l $SSH_USER $etcd_host_ip sudo coreos-cloudinit --from-file /usr/share/oem/cloud-config.yml
done

# config controller
#for controller_host_ip in $(echo $CONTROLLER_HOST_IPS | sed 's/,/ /g'); do
#	scp -i $SSH_IDENTITY_FILE -r ./controller "${SSH_USER}@${controller_host_ip}:/tmp"
#	ssh -i $SSH_IDENTITY_FILE -l $SSH_USER $controller_host_ip /tmp/controller/config.sh
#done

# config worker
#for worker_host_ip in $(echo $WORKER_HOST_IPS | sed 's/,/ /g'); do
#	scp -i $SSH_IDENTITY_FILE -r ./worker "${SSH_USER}@${worker_host_ip}:/tmp"
#	ssh -i $SSH_IDENTITY_FILE -l $SSH_USER $worker_host_ip /tmp/worker/config.sh
#done
