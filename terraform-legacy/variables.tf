variable "project_name" {
  default = "terraform-project"
  description = "name of project"
}

variable "aws_access_key" {
  description = "AWS access key"
}

variable "docker_host_amis" {
  default = {
    us-west-1 = "ami-c0563da0"
  }

  description = "docker host AMIs"
}

variable "aws_region" {
  default = "us-east-1"
  description = "AWS region"
}

variable "aws_availability_zone" {
  default = "us-east-1b"
  description = "AWS availability zone"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "aws_zone_id" {
  default = "Z1HZT86NH0DNVA"
  description = "AWS hosted zone id"
}

variable "aws_record_name" {
  default = "cluster.calldrive.com"
  description = "domain to use"
}

variable "mongo_version" {
  default = "3.2"
  description = "mongo docker image version"
}

variable "nginx_version" {
  default = "1.9.9"
  description = "nginx docker image version"
}

variable "private_key_path" {
  description = "path to ssh private key"
}

variable "public_key_path" {
  description = "path to ssh public key"
}

variable "COOKIE_SECRET" {}
variable "MONGO_URI" {}
variable "NODE_ENV" {}
variable "PORT" {}
variable "STRIPE_SECRET_KEY" {}
variable "STRIPE_PUBLISHABLE_KEY" {}
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "MANDRILL_API_KEY" {}
variable "STORMPATH_CLIENT_APIKEY_ID" {}
variable "STORMPATH_CLIENT_APIKEY_SECRET" {}
variable "STORMPATH_APPLICATION_HREF" {}
                      
