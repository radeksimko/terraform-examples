variable "region" {
	default = "us-central1"
}

variable "region_zone" {
	default = "us-central1-f"
}

variable "project_name" {
	description = "The ID of the Google Cloud project"
}

variable "account_file_path" {
	description = "Path to the JSON file used to describe your account credentials"
}

variable "public_key_path" {
	description = "Path to the public part of SSH key"
}

variable "private_key_path" {
	description = "Path to the private part of SSH key"
}
