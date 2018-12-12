# Terraform Windows Example
This repo builds a linux permanent peer, and a windows instance.  The provisioners for the windows service install the habitat supervisor as a service, and loads the core/mysql service with a custom user toml, and optional auth token.

## Setup
In order to use the example code in this repo you will need to have the following configured:

- [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
- [Create AWS Account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html)

## Configure
`cp terraform.tfvars.example terraform.tfvars` and modify as needed

## Build
1. `terraform init`
2. `terraform apply`

## Notes
In general, the automated steps required to provision a windows server running a habitat service are as follows:
- In user data:
  - winrm open on firewall
  - _windows password set_ (optional)
- In terraform provisioner(s)
  - _firewall ports for hab supervisor_ (optional)
  - install chocolatey
  - install habitat
  - install core/windows_service
  - _configure windows service to point to permanent peer_ (optional)
  - _start windows service (and sleep 15s)_ (optional)
  - _add user toml dir and contents_ (optional)
  - _add auth token env var_ (optional)
  - hab svc load <your package> <your flags>


