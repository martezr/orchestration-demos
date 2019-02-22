variable "image" {}
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "grt-tf-bucket"
    key    = "stackstorm/terraform.tfstate"
    region = "us-east-1"
  }
}

module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "1.12.0"

  name                   = "test-instance"
  instance_count         = 1

  ami                    = "${var.image}"
  instance_type          = "t2.micro"
  key_name               = "InSpecDemo"
  monitoring             = false
  vpc_security_group_ids = ["sg-0a61bb03e71dcbaed"]
  subnet_id              = "subnet-53586237"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
