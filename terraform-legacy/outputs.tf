output "reverse proxy public ip" {
  value = "${aws_instance.reverse_proxy.public_ip}"
}
