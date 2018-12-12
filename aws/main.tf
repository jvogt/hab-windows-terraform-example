terraform {
  required_version = "> 0.11.0"
}

provider "aws" {
  profile                 = "${var.aws_profile}"
  shared_credentials_file = "~/.aws/credentials"
  region                  = "${var.aws_region}"
}

////////////////////////////////
// AMIs

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["446539779517"]

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-*"]
  }
}

data "aws_ami" "win2016" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
}

resource "random_id" "mysql_id" {
  byte_length = 4
}
