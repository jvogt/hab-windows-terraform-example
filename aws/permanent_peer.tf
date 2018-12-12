resource "aws_instance" "permanent-peer" {
  connection {
    user        = "centos"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "t3.small"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.default.id}"
  vpc_security_group_ids      = ["${aws_security_group.mysql.id}"]
  associate_public_ip_address = true

  tags {
    Name          = "${var.aws_key_pair_name}-permanentpeer"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "mysql-win"
    X-Application = "mysql-win"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "habitat" {
    permanent_peer = true
    use_sudo     = true
    service_type = "systemd"

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "centos"
      private_key = "${file("${var.aws_key_pair_file}")}"
    }
  }
}
