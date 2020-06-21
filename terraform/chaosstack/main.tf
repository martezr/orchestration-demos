terraform {
  backend "local" {}
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
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
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    subnet_id = "subnet-03a54f2d"
    security_groups  = [aws_security_group.chaosstack-securitygroup.id]
  }
}

resource "aws_autoscaling_group" "chaos" {
  name = "chaosstack"
  availability_zones = ["us-east-1b"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2

  launch_template {
    id      = aws_launch_template.chaos_launch_template.id
    version = "$Latest"
  }
}

resource "aws_security_group" "chaosstack-securitygroup" {
  description = "Chaos Stack Security Group"
  name        = "chaosstack-securitygroup"
  vpc_id      = "vpc-5523f52e"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}