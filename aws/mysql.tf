data "template_file" "win_service" {
  template = "${file("${path.module}/templates/HabService.exe.config")}"

  vars {
    flags = "--auto-update --peer ${aws_instance.permanent-peer.private_ip} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631"
  }
}

data "template_file" "install_mysql" {
  template = "${file("${path.module}/templates/install_mysql.ps1")}"
  vars {
    release_channel = "${var.hab_release_channel}"
    origin = "${var.origin}"
    hab_auth_token = "${var.builder_auth_token}"
  }
}

data "template_file" "mysql_user_toml" {
  template = "${file("${path.module}/templates/mysql_user.toml")}"
  vars {
    app_username = "${var.mysql_app_user}"
    app_password = "${var.mysql_app_password}"
  }
}


resource "aws_instance" "mysql" {
  depends_on                  = ["aws_instance.permanent-peer"]
  ami                         = "${data.aws_ami.win2016.id}"
  instance_type               = "m4.xlarge"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.default.id}"
  vpc_security_group_ids      = ["${aws_security_group.mysql.id}"]
  associate_public_ip_address = true
  
  root_block_device {
    volume_size = 80
  }

  tags {
    Name          = "${var.aws_key_pair_name}-mysql"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "mysql"
    X-Application = "mysql"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }

  provisioner "file" {
    content     = "${data.template_file.install_mysql.rendered}"
    destination = "c:\\install_mysql.ps1"
    connection  = {
      type     = "winrm"
      user     = "Administrator"
      password = "${var.windows_admin_password}"
      insecure = true
      https    = false
    }
  }

  provisioner "file" {
    content     = "${data.template_file.win_service.rendered}"
    destination = "c:\\HabService.exe.config"
    connection  = {
      type     = "winrm"
      user     = "Administrator"
      password = "${var.windows_admin_password}"
      insecure = true
      https    = false
    }
  }
  provisioner "file" {
    content     = "${data.template_file.mysql_user_toml.rendered}"
    destination = "c:\\mysql_user.toml"
    connection  = {
      type     = "winrm"
      user     = "Administrator"
      password = "${var.windows_admin_password}"
      insecure = true
      https    = false
    }
  }
  provisioner "remote-exec" {
    connection = {
      type     = "winrm"
      user     = "Administrator"
      password = "${var.windows_admin_password}"
      insecure = true
      https    = false
    }
    inline = [
      "powershell c:\\install_mysql.ps1",
    ]
  }
  user_data = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}

</script>
<powershell>
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  # Set Administrator password
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${var.windows_admin_password}")
</powershell>
EOF
}