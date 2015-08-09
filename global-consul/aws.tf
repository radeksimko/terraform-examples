provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_iam_instance_profile" "consul" {
    name = "consul"
    roles = ["${aws_iam_role.consul.name}"]
}

resource "aws_iam_role" "consul" {
    name = "consul"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {"AWS": "*"},
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "consul" {
    name = "consul"
    role = "${aws_iam_role.consul.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_instance" "consul" {
  count = "${var.aws_min_size}"

  ami = "ami-57e8d767"
  availability_zone = "${var.aws_az}"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  security_groups = ["${aws_security_group.default.name}"]

  iam_instance_profile = "${aws_iam_instance_profile.consul.name}"
  user_data = <<SCRIPT
#!/bin/bash
${file("${path.root}/scripts/install-deps.sh")}
SERVER_COUNT="${var.aws_min_size}"
WAN_JOIN_ADDR="${join(" ", google_compute_address.consul.*.address)}"
${file("${path.root}/scripts/get-metadata-aws.sh")}
${file("${path.root}/scripts/startup.sh")}
SCRIPT

  tags {
      Name = "consul-node"
      Group = "consul"
  }
}

resource "aws_instance" "consul_web_ui" {
  ami = "ami-57e8d767"
  availability_zone = "${var.aws_az}"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  security_groups = ["${aws_security_group.default.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.consul.name}"

  user_data = <<SCRIPT
#!/bin/bash
${file("${path.root}/scripts/install-deps.sh")}
CONSUL_HTTP_ADDR="0.0.0.0:80"
WAN_JOIN_ADDR="${join(" ", google_compute_address.consul.*.address)}"
${file("${path.root}/scripts/get-metadata-aws.sh")}
${file("${path.root}/scripts/ui-startup.sh")}
SCRIPT

  tags {
      Name = "tf-consul-ui"
  }
}

resource "aws_security_group" "default" {
    name = "consul"
    description = "Consul internal traffic + maintenance."

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        self = true
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: Restrict to GCE only
    }
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: Restrict to GCE only
    }

    ingress {
        from_port = 8500
        to_port = 8500
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}