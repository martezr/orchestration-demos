terraform {
  backend "local" {
    path = "/stackstorm/chaosstack.tfstate"
  }
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
  key_name = "InSpecDemo"
  
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
      delete_on_termination = true
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    subnet_id = "subnet-03a54f2d"
    security_groups  = [aws_security_group.chaosstack-securitygroup.id]
  }
  user_data = filebase64("${path.module}/web.sh")
}

resource "aws_lb" "chaos_alb" {
  name               = "chaosstack-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.chaosstack-securitygroup.id]
  subnets            = ["subnet-03a54f2d","subnet-09ee0db307346fafd"]

  tags = {
    Name = "chaosstack-alb"
  }
}

resource "aws_lb_listener" "chaos_listener" {
  load_balancer_arn = aws_lb.chaos_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chaos_tg.arn
  }
}

resource "aws_lb_target_group" "chaos_tg" {
  name     = "chaosstack-targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-5523f52e"
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.chaos_asg.id
  alb_target_group_arn   = aws_lb_target_group.chaos_tg.arn
}

resource "aws_autoscaling_group" "chaos_asg" {
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