provider "google" {
    region = "${var.region}"
    project = "${var.project_name}"
    account_file = "${file(var.account_file_path)}"
}

resource "google_compute_http_health_check" "consul" {
    name = "tf-consul-example"
    request_path = "/"
    check_interval_sec = 1
    healthy_threshold = 1
    unhealthy_threshold = 10
    timeout_sec = 1
}

resource "google_compute_target_pool" "default" {
    name = "tf-consul-example"
    instances = ["${google_compute_instance.consul.*.self_link}"]
    health_checks = ["${google_compute_http_health_check.consul.name}"]
}

resource "google_compute_instance" "consul" {
    count = "${var.servers}"

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
            # Ephemeral
        }
    }

    metadata {
        startup-script = <<SCRIPT
${file("${path.module}/scripts/install-deps.sh")}
SERVER_COUNT="${var.servers}"
INSTANCE_MASK="tf-consul-.*"
${file("${path.module}/scripts/get-metadata-gce.sh")}
${file("${path.module}/scripts/startup.sh")}
SCRIPT
        shutdown-script = "${file("${path.module}/scripts/shutdown.sh")}"
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
        datacentreName = "gce-${var.region_zone}"
        startup-script = <<SCRIPT
${file("${path.module}/scripts/install-deps.sh")}
${file("${path.module}/scripts/get-metadata-gce.sh")}
${file("${path.module}/scripts/ui-startup.sh")}
SCRIPT
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
