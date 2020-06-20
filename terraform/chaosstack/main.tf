terraform {
  backend "local" {}
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name  = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_launch_template" "chaos_launch_template" {
  name_prefix   = "chaos"
  image_id      = data.aws_ami.centos.id
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "chaos" {
  name = "chaosstack"
  availability_zones = ["us-east-1a","us-east-1b"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2

  launch_template {
    id      = "${aws_launch_template.chaos_launch_template.id}"
    version = "$Latest"
  }
}