output "gce_node_public_ips" {
	value = "${join(" ", google_compute_instance.consul.*.network_interface.0.access_config.0.nat_ip)}"
}
output "gce_ui" {
	value = "${google_compute_instance.consul_web_ui.network_interface.0.access_config.0.nat_ip}"
}

output "aws_node_public_ips" {
	value = "${join(" ", aws_instance.consul.*.public_ip)}"
}
output "aws_ui" {
	value = "${aws_instance.consul_web_ui.public_ip}"
}
