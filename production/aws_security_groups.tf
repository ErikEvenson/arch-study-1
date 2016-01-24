# outbound
resource "aws_security_group" "outbound" {
  name        = "outbound security group"
  description = "outbound security group for ${var.project_name}"
  vpc_id      = "${aws_vpc.default.id}"

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

# http
resource "aws_security_group" "http" {
  name        = "http security group"
  description = "http security group for ${var.project_name}"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project_name}"
  }
}

# https
resource "aws_security_group" "https" {
  name        = "https security group"
  description = "https security group for ${var.project_name}"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project_name}"
  }
}

# ssh
resource "aws_security_group" "ssh" {
  name        = "ssh security group"
  description = "ssh security group for ${var.project_name}"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project_name}"
  }
}
