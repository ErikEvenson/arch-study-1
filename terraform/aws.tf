# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16" # 10.0.0.0 - 10.0.255.255

  tags {
    Name = "${var.project_name}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.project_name}"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default.id}"
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.0.0/24" # 10.0.0.0 - 10.0.0.255
  map_public_ip_on_launch = true

  tags {
    Name = "${var.project_name}"
  }
}

# A security group for the reverse proxy so it is accessible via the web
resource "aws_security_group" "reverse_proxy" {
  name        = "reverse proxy security group"
  description = "reverse proxy security group for ${var.project_name}"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere (for provisioning)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project_name}"
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "default security group"
  description = "default secutity group for ${var.project_name}"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere (for provisioning)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project_name}"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "calldrive"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "reverse_proxy" {
  private_ip = "10.0.0.4" # parameterize?
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    agent = false
    key_file = "${var.private_key_path}"
    user = "ubuntu"
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.docker_host_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.reverse_proxy.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.public.id}"

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/reverse-proxy-files/conf"
    ]
  }

  provisioner "file" {
      source = "reverse-proxy-files/conf/"
      destination = "/home/ubuntu/reverse-proxy-files/conf"
  }

  provisioner "file" {
      source = "reverse-proxy-files/usr-share-nginx/"
      destination = "/home/ubuntu/reverse-proxy-files/usr-share-nginx"
  }

  provisioner "remote-exec" {
    inline = [
      "docker run --name nginx-reverse-proxy -p 80:80 \\",
        "-v /home/ubuntu/reverse-proxy-files/conf/nginx.conf:\\",
          "/etc/nginx/nginx.conf:ro \\",
        "-v /home/ubuntu/reverse-proxy-files/usr-share-nginx:\\",
          "/usr/share/nginx:ro \\",
        "-d nginx:${var.nginx_version}"
    ]
  }

  tags {
    Name = "${var.project_name}"
  }
}

resource "aws_instance" "docker_host" {
  private_ip = "10.0.0.5" # parameterize?

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    agent = false
    key_file = "${var.private_key_path}"
    user = "ubuntu"
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.docker_host_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.public.id}"

  provisioner "remote-exec" {
    inline = [
      "docker run --name mongo -d -p 27017:27017 mongo:${var.mongo_version}",
      "docker login -e devadmin@calldrive.com -p ERm8qQv7OMhF -u calldrive",
      "docker run \\",
        "-e 'COOKIE_SECRET=${var.COOKIE_SECRET}' \\",
        "-e 'MONGO_URI=${var.MONGO_URI}' \\",
        "-e 'NODE_ENV=${var.NODE_ENV}' \\",
        "-e 'PORT=${var.PORT}' \\",
        "-e 'STRIPE_SECRET_KEY=${var.STRIPE_SECRET_KEY}' \\",
        "-e 'STRIPE_PUBLISHABLE_KEY=${var.STRIPE_PUBLISHABLE_KEY}' \\",
        "-e 'AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID}' \\",
        "-e 'AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY}' \\",
        "-e 'MANDRILL_API_KEY=${var.MANDRILL_API_KEY}' \\",
        "-e 'STORMPATH_CLIENT_APIKEY_ID=${var.STORMPATH_CLIENT_APIKEY_ID}' \\",
        "-e 'STORMPATH_CLIENT_APIKEY_SECRET=${var.STORMPATH_CLIENT_APIKEY_SECRET}' \\",
        "-e 'STORMPATH_APPLICATION_HREF=${var.STORMPATH_APPLICATION_HREF}' \\",
        "--name sedna-app -d --link mongo \\",
        "-p 80:5000 -u root -w /opt/app calldrive/sedna-app:latest npm start"
    ]
  }

  tags {
    Name = "${var.project_name}"
  }
}

# Set up DNS records
resource "aws_route53_record" "cluster" {
   zone_id = "${var.aws_zone_id}"
   name = "${var.aws_record_name}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.reverse_proxy.public_ip}"]
}
