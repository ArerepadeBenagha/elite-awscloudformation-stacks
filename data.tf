data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


########------- Bastion-SG -------------##########
data "aws_security_group" "webserver-sg" {
  id = "sg-0ebee6d9cc96e859b"
}
data "aws_subnet" "public-subnet-2" {
  id = "subnet-0ad066a9178119cbb"
}
data "aws_subnet" "private-subnet-2" {
  id = "subnet-0a6227d962143c7ca"
}

##ALB-SG

data "aws_security_group" "alb-sg" {
  id = "sg-0b0b7124169bb2789"
}
data "aws_subnet" "alb-public-1" {
  id = "subnet-0b48a8917d61924d7"
}
data "aws_subnet" "alb-public-2" {
  id = "subnet-0ad066a9178119cbb"
}

###VPC
data "aws_vpc" "vpc-stack" {
  id = "vpc-002847ce027cbe983"
}

data "aws_internet_gateway" "int-gw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}