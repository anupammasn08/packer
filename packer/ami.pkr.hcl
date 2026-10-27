
packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "service_name" {
  type    = string
  default = "ami"
}

variable "service_version" {
  type    = string
  default = "1.0.0"
}

variable "source_ami" {
  type    = string
  default = "ami-05eca858e2227a6ff"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

source "amazon-ebs" "ami" {
  ami_name      = "${var.service_name}-${var.service_version}"
  instance_type = "t3.micro"
  region        = var.aws_region
  source_ami    = var.source_ami
  ssh_username  = "ubuntu"
  ssh_timeout   = "10m"
}

build {
  sources = ["source.amazon-ebs.ami"]

provisioner "ansible" {
  playbook_file = "./ansible/playbook-ami.yml"
  user          = "ubuntu"
  use_proxy     = false # Disables the internal Packer proxy

  extra_arguments = [
    "--scp-extra-args", "'-O'", # Fixes transfer failures with newer SSH versions
    "--ssh-extra-args", "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  ]

  ansible_env_vars = [
    "ANSIBLE_REMOTE_TEMP=/tmp" # Alternative temp directory to avoid home dir issues
  ]
}
}
