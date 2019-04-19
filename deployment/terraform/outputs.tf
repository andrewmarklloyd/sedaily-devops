output "instance_ip_addr" {
  value = "${aws_instance.sedaily.public_ip}"
}
