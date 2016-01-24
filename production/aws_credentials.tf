# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_key_pair" "auth" {
  key_name   = "arch-study-1"
  public_key = "${file(var.public_key_path)}"
}
