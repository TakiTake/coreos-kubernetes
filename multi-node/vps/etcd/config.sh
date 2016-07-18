#!/bin/bash

docker run --rm --env-file /etc/environment --env-file /tmp/etc/environment -v /usr/share/oem:/work/oem -v /tmp/etcd:/work/script \
	ruby:2.3-alpine \
	ruby /work/script/config.rb
