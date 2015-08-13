variable "project_name" {}
variable "account_file_path" {}

module "consul" {
	source = "github.com/radeksimko/terraform-examples//google-consul"
	project_name = "${var.project_name}"
	account_file_path = "${var.account_file_path}"
	servers = 5
}

output "ui_url" {
	value = "${module.consul.consul_ui}"
}
