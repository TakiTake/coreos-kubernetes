ETCD_PRIVATE_IPS = ENV.fetch('ETCD_PRIVATE_IPS')
CONTROLLER_PUBLIC_IPS = ENV.fetch('CONTROLLER_PUBLIC_IPS')
K8S_ENV_FILE = '/work/coreos-kubernetes/options.env'

def etcd_endpoints(ips)
  ips.split(',').map{ |ip| "http://#{ip}:2379" }.join(",")
end

def controller_endpoint(ips)
  ips.split(',').map{ |ip| "https://#{ip}" }.first
end

open(K8S_ENV_FILE, 'w+') do |f|
  f.write("ETCD_ENDPOINTS=#{etcd_endpoints(ETCD_PRIVATE_IPS)}\n")
  f.write("CONTROLLER_ENDPOINT=#{controller_endpoint(CONTROLLER_PUBLIC_IPS)}\n")
end
