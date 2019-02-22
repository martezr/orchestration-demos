variable "image" {}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "grt-tf-bucket"
    key    = "stackstorm/terraform.tfstate"
    region = "us-east-1"
  }
}

module "ec2_cluster" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "1.12.0"

  name                        = "test-instance"
  instance_count              = 1

  ami                         = "${var.image}"
  instance_type               = "t2.micro"
  key_name                    = "InSpecDemo"
  monitoring                  = false
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-084c9b0de69d8c79b"]
  subnet_id                   = "subnet-53586237"
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
