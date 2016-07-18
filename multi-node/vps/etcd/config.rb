require 'yaml'

def initial_cluster(ips)
  ips.split(',').map.with_index { |ip, i| "infra%02d=http://#{ip}:2380" % i }.join(',')
end

def unit_exist_in?(unit_name, data)
  data['coreos']['units'].any? { |unit| unit['name'] == unit_name }
end

# docker mount oem dir to /work/oem
CLOUD_CONFIG_PATH = '/work/oem/cloud-config.yml'
ETCD_INDX = ENV.fetch('ETCD_HOST_IPS').split(',').index(ENV.fetch('COREOS_PUBLIC_IPV4'))

data = YAML.load(IO.readlines(CLOUD_CONFIG_PATH)[1..-1].join)
data['coreos']['etcd2'] = {}
data['coreos']['etcd2']['name'] = "infra%02d" % ETCD_INDX
data['coreos']['etcd2']['initial-cluster'] = initial_cluster(ENV.fetch('ETCD_CLUSTER_IPS'))
data['coreos']['etcd2']['initial-cluster-token'] = 'etcd-cluster-1'
data['coreos']['etcd2']['initial-cluster-state'] = 'new'
data['coreos']['etcd2']['advertise-client-urls'] = 'http://$private_ipv4:2379'
data['coreos']['etcd2']['listen-client-urls'] = 'http://0.0.0.0:2379'
data['coreos']['etcd2']['initial-advertise-peer-urls'] = 'http://$private_ipv4:2380'
data['coreos']['etcd2']['listen-peer-urls'] = 'http://$private_ipv4:2380'

unless unit_exist_in?('etcd2.service', data)
  data['coreos']['units'] << {
    'name' => 'etcd2.service',
    'command' => 'start'
  }
end

IO.write(CLOUD_CONFIG_PATH, "#cloud-config\n#{data.to_yaml}")
