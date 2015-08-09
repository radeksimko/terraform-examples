output "consul_ui" {
	value = "http://${google_compute_instance.consul_web_ui.network_interface.0.access_config.0.nat_ip}:8500"
}
