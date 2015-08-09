variable "region" {
	default = "us-central1"
	description = "The region of Google Cloud where to launch the cluster."
}

variable "region_zone" {
	default = "us-central1-f"
	description = "The zone of Google Cloud in which to launch the cluster."
}

variable "project_name" {
	description = "Google Cloud project name."
}

variable "account_file_path" {
	description = "Path to the JSON file used to describe your account credentials, downloaded from Google Cloud Console."
}

variable "servers" {
	default = 3
	description = "The number of Consul servers to launch."
}
