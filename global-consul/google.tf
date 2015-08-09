provider "google" {
    region = "${var.region}"
    project = "${var.project_name}"
    account_file = "${file(var.account_file_path)}"
}

resource "google_compute_address" "consul" {
    count = "${var.gce_servers}"
    name = "consul-${count.index}"
}

resource "google_compute_instance" "consul" {
    count = "${var.gce_servers}"

    name = "tf-consul-${count.index}"
    machine_type = "f1-micro"
    zone = "${var.region_zone}"
    tags = ["consul-node"]

    disk {
        image = "ubuntu-os-cloud/ubuntu-1204-precise-v20150625"
    }

    network_interface {
        network = "default"
        access_config {
            nat_ip = "${element(google_compute_address.consul.*.address, count.index)}"
        }
    }

    metadata {
        startup-script = <<SCRIPT
${file("${path.root}/scripts/install-deps.sh")}
WAN_JOIN_ADDR="${join(" ", aws_instance.consul.*.public_ip)}"
SERVER_COUNT="${var.gce_servers}"
INSTANCE_MASK="tf-consul-.*"
${file("${path.root}/scripts/get-metadata-gce.sh")}
${file("${path.root}/scripts/startup.sh")}
SCRIPT
        shutdown-script = "${file("${path.root}/scripts/shutdown.sh")}"
    }

    service_account {
        scopes = ["https://www.googleapis.com/auth/compute.readonly"]
    }
}

resource "google_compute_instance" "consul_web_ui" {
    name = "tf-consul-ui"
    machine_type = "f1-micro"
    zone = "${var.region_zone}"
    tags = ["consul-web-ui"]

    disk {
        image = "ubuntu-os-cloud/ubuntu-1204-precise-v20150625"
    }

    network_interface {
        network = "default"
        access_config {
            # Ephemeral IP
        }
    }

    metadata {
        startup-script = <<SCRIPT
${file("${path.root}/scripts/install-deps.sh")}
CONSUL_HTTP_ADDR="0.0.0.0:80"
INSTANCE_MASK="tf-consul-.*"
WAN_JOIN_ADDR="${join(" ", aws_instance.consul.*.public_ip)}"
${file("${path.root}/scripts/get-metadata-gce.sh")}
${file("${path.root}/scripts/ui-startup.sh")}
SCRIPT
        shutdown-script = "${file("${path.root}/scripts/shutdown.sh")}"
    }

    service_account {
        scopes = ["https://www.googleapis.com/auth/compute.readonly"]
    }
}

resource "google_compute_firewall" "consul_ingress" {
    name = "consul-int-firewall"
    network = "default"

    allow {
        protocol = "tcp"
        ports = [
            "8300", # Server RPC
            "8301", # Serf LAN
            "8400"  # RPC
        ]
    }

    source_tags = ["consul-node", "consul-web-ui"]
    target_tags = ["consul-node", "consul-web-ui"]
}

resource "google_compute_firewall" "consul_admin_node" {
    name = "consul-admin-firewall"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_tags = ["consul-web-ui"]
    target_tags = ["consul-node"]
}

resource "google_compute_firewall" "consul_ui" {
    name = "consul-ui-firewall"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["8500", "22"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["consul-web-ui"]
}

resource "google_compute_firewall" "consul_ext" {
    name = "consul-ext-firewall"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["1-65535"]
    }
    allow {
        protocol = "udp"
        ports = ["1-65535"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["consul-node"] # TODO: Restrict to AWS only
}
