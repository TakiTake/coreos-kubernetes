#!/bin/bash -ex

sudo mkdir -p /etc/kubernetes/ssl
sudo tar -C /etc/kubernetes/ssl -xf /tmp/ssl.tar

sudo mkdir -p /run/coreos-kubernetes
docker run --rm --env-file /tmp/etc/environment -v /run/coreos-kubernetes:/work/coreos-kubernetes -v /tmp/controller:/work/script \
  ruby:2.3-alpine \
  ruby /work/script/config.rb

sudo /bin/bash /tmp/controller/install.sh
