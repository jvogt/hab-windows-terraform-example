output "public_ips_permanent_peer" {
  value = "${aws_instance.permanent-peer.public_ip}"
}

output "public_ips_mysql" {
  value = "${aws_instance.mysql.public_ip}"
}
