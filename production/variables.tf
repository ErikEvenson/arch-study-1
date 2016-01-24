variable "project_name" {
  default = "terraform-project"
  description = "name of project"
}

variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_region" {
  default = "us-west-1"
  description = "AWS region"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "docker_host_amis" {
  default = {
    us-west-1 = "ami-c0563da0"
  }

  description = "docker host AMIs"
}

variable "private_key_path" {
  description = "path to ssh private key"
}

variable "public_key_path" {
  description = "path to ssh public key"
}
