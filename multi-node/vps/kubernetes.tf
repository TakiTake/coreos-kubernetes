resource "digitalocean_droplet" "kubernetes-controller" {
	image = "coreos-beta"
	name = "kubenetes-controller"
	region = "sgp1"
	size = "512mb"
	private_networking = true
	backups = false
	ipv6 = false
	ssh_keys = [
		"${var.ssh_fingerprint}"
	]
}

output "controller-ip" {
	value = "${digitalocean_droplet.kubernetes-controller.ipv4_address}"
}
