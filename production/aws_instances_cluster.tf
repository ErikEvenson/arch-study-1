variable "cluster_node_1_ip" {
  default = "10.0.0.104"
  description = "cluster node 1 ip"
}

variable "cluster_node_2_ip" {
  default = "10.0.0.105"
  description = "cluster node 2 ip"
}

variable "cluster_node_3_ip" {
  default = "10.0.0.106"
  description = "cluster node 3 ip"
}

resource "aws_instance" "cluster_node_1" {
  depends_on = [
    "aws_instance.consul_node_1",
    "aws_instance.consul_node_2",
    "aws_instance.consul_node_3"
  ]

  private_ip = "${var.cluster_node_1_ip}"
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
  vpc_security_group_ids = [
    "${aws_security_group.consul.id}",
    "${aws_security_group.outbound.id}",
    "${aws_security_group.ssh.id}"
  ]

  # Launch into the public subnet.
  subnet_id = "${aws_subnet.public.id}"

  provisioner "remote-exec" {
    inline = [
      "docker run \\",
        "-p 8300:8300 \\",
        "-p 8301:8301 \\",
        "-p 8301:8301/udp \\",
        "-p 8302:8302 \\",
        "-p 8302:8302/udp \\",
        "-p 8400:8400 \\",
        "-p 8500:8500 \\",
        "-p 53:8600/udp \\",
        "-d -v /mnt:/data \\",
        "gliderlabs/consul-server:0.6 -advertise '${var.cluster_node_1_ip}' \\",
        "-client 0.0.0.0 -join '${var.consul_node_1_ip}'",

      "docker run -d \\",
        "--net=host \\",
        "--volume=/var/run/docker.sock:/tmp/docker.sock \\",
        "gliderlabs/registrator:latest \\",
          "-ip '${var.cluster_node_1_ip}' \\",
          "consul://'${var.cluster_node_1_ip}':8500",

      "docker run -d -P asakaguchi/docker-nodejs-hello-world"
    ]
  }

  tags {
    Name = "${var.project_name}"
  }
}

resource "aws_instance" "cluster_node_2" {
  depends_on = [
    "aws_instance.consul_node_1",
    "aws_instance.consul_node_2",
    "aws_instance.consul_node_3"
  ]

  private_ip = "${var.cluster_node_2_ip}"
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
  vpc_security_group_ids = [
    "${aws_security_group.consul.id}",
    "${aws_security_group.outbound.id}",
    "${aws_security_group.ssh.id}"
  ]

  # Launch into the public subnet.
  subnet_id = "${aws_subnet.public.id}"

  provisioner "remote-exec" {
    inline = [
      "docker run \\",
        "-p 8300:8300 \\",
        "-p 8301:8301 \\",
        "-p 8301:8301/udp \\",
        "-p 8302:8302 \\",
        "-p 8302:8302/udp \\",
        "-p 8400:8400 \\",
        "-p 8500:8500 \\",
        "-p 53:8600/udp \\",
        "-d -v /mnt:/data \\",
        "gliderlabs/consul-server:0.6 -advertise '${var.cluster_node_2_ip}' \\",
        "-client 0.0.0.0 -join '${var.consul_node_1_ip}'",

      "docker run -d \\",
        "--net=host \\",
        "--volume=/var/run/docker.sock:/tmp/docker.sock \\",
        "gliderlabs/registrator:latest \\",
          "-ip '${var.cluster_node_2_ip}' \\",
          "consul://'${var.cluster_node_2_ip}':8500"
    ]
  }

  tags {
    Name = "${var.project_name}"
  }
}

resource "aws_instance" "cluster_node_3" {
  depends_on = [
    "aws_instance.consul_node_1",
    "aws_instance.consul_node_2",
    "aws_instance.consul_node_3"
  ]

  private_ip = "${var.cluster_node_3_ip}"
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
  vpc_security_group_ids = [
    "${aws_security_group.consul.id}",
    "${aws_security_group.outbound.id}",
    "${aws_security_group.ssh.id}"
  ]

  # Launch into the public subnet.
  subnet_id = "${aws_subnet.public.id}"

  provisioner "remote-exec" {
    inline = [
      "docker run \\",
        "-p 8300:8300 \\",
        "-p 8301:8301 \\",
        "-p 8301:8301/udp \\",
        "-p 8302:8302 \\",
        "-p 8302:8302/udp \\",
        "-p 8400:8400 \\",
        "-p 8500:8500 \\",
        "-p 53:8600/udp \\",
        "-d -v /mnt:/data \\",
        "gliderlabs/consul-server:0.6 -advertise '${var.cluster_node_3_ip}' \\",
        "-client 0.0.0.0 -join '${var.consul_node_1_ip}'",

      "docker run -d \\",
        "--net=host \\",
        "--volume=/var/run/docker.sock:/tmp/docker.sock \\",
        "gliderlabs/registrator:latest \\",
          "-ip '${var.cluster_node_3_ip}' \\",
          "consul://'${var.cluster_node_3_ip}':8500"
    ]
  }

  tags {
    Name = "${var.project_name}"
  }
}
