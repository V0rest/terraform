/*
## vpc.tf
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  tags = {
    Name = "${var.env}_vpc"
    Env  = var.env
  }
}
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.env}_subnet"
    Env  = var.env
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.idtags = {
    Name = "${var.env}_gw"
    Env  = var.env
  }
}
resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_idroute {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }tags = {
    Name = "default route table"
    env  = var.env
  }
}
*/


provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Create vpc
resource "aws_vpc" "var.instanceName_vpc" {
  cidr_block           = "${var.vpcCIDRblock}"
  instance_tenancy     = "${var.instanceTenancy}"
  enable_dns_support   = "${var.dnsSupport}"
  enable_dns_hostnames = "${var.dnsHostNames}"
  tags = {
    Name = "${var.instanceName}-${var.region}-vpc" # "Jenkins-Debian-us-east-2-vpc"
  }
}

#Create subnet -1
resource "aws_subnet" "${var.instanceName}_subnet-1" {
vpc_id                  = aws_vpc."${var.instanceName}"_vpc.id
  cidr_block              = "${var.subnetCIDRblock}"
  map_public_ip_on_launch = "${var.mapPublicIP}"
  availability_zone       = "${var.availabilityZone}"

  tags = {
    Name = "${var.instanceName-var.region}-subnet-1" #"Jenkins-Debian-us-east-2-subnet-1"
  }
}

#Create Security group -1
resource "aws_security_group" "${var.instanceName}_sg-1" {
name = "Jenkins Security Group"
description = "Allow tcp 22,443,8080"
  vpc_id      = aws_vpc.${var.instanceName}_vpc.id

ingress {
description = "Allow ssh"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ${var.ingressCIDRblock}
}

ingress {
description = "Allow 443"
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = ${var.ingressCIDRblock}
}

ingress {
description = "Allow 8080"
from_port = 8080
to_port = 8080
protocol = "tcp"
cidr_blocks = ${var.ingressCIDRblock}
}

ingress {
description = "Allow icmp"
from_port = "-1"
to_port = "-1"
protocol = "icmp"
cidr_blocks = ${var.ingressCIDRblock}
}

egress {
description = "Allow all out"
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "${var.instanceName-var.region}-sg" # "Jenkins-Debian-us-east-2-security group"
  }
}

#Create ACL-1
resource "aws_network_acl" "${var.instanceName}_nacl" {
  vpc_id = aws_vpc.${var.instanceName}_vpc.id
subnet_ids = [aws_subnet.${var.instanceName}_subnet-1.id]

  # allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = ${var.destinationCIDRblock}
    from_port  = 22
    to_port    = 22
  }

  # allow ingress port 8080
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = ${var.destinationCIDRblock}
    from_port  = 8080
    to_port    = 8080
  }

  # allow egress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = ${var.destinationCIDRblock}
    from_port  = 80
    to_port    = 80
  }

  # allow ingress port 443
  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = ${var.destinationCIDRblock}
    from_port  = 443
    to_port    = 443
  }

  # allow ingress ephemeral ports
    ingress {
      protocol   = "tcp"
      rule_no    = 500
      action     = "allow"
      cidr_block = ${var.destinationCIDRblock}
      from_port  = 1024
      to_port    = 65535
    }

  # allow egress port 22
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = ${var.destinationCIDRblock}
    from_port  = 22
    to_port    = 22
  }

  # allow egress port 8080
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = ${var.destinationCIDRblock}
    from_port  = 8080
    to_port    = 8080
  }

  # allow egress port 80
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = ${var.destinationCIDRblock}
    from_port  = 80
    to_port    = 80
  }

  # allow egress port 443
  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = ${var.destinationCIDRblock}
    from_port  = 443
    to_port    = 443
  }

  # allow egress ephemeral ports
    egress {
      protocol   = "tcp"
      rule_no    = 500
      action     = "allow"
      cidr_block = ${var.destinationCIDRblock}
      from_port  = 1024
      to_port    = 65535
    }

  tags = {
    Name = "${var.instanceName-var.region}-nacl" #"Jenkins-Debian-us-east-2-nacl"
  }
}

#Create internet gateway
resource "aws_internet_gateway" "${var.instanceName}_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "${var.instanceName-var.region}-igw" #"Jenkins-Debian-us-east-2-jenkins ineternet gateway"
  }
}

#Create route table-1
resource "aws_route_table" "${var.instanceName}_rt-1" {
  vpc_id = aws_vpc.${var.instanceName}_vpc.id
/*
  route {
    cidr_block = "172.31.0.0/16"
    gateway_id =aws_internet_gateway.jenkins_private-gateway.id
  }
*/

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_internet_gateway.${var.instanceName}_igw.id

  }

  tags = {
    Name = "${var.instanceName-var.region}-route-1" # "Jenkins-Debian-us-east-2-jenkins route-1"
  }
}
# Create the Internet Access
resource "aws_route" "${var.instanceName}_internet_access" {
  route_table_id         = aws_route_table.${var.instanceName}_rt-1.id
  destination_cidr_block = ${var.destinationCIDRblock}
  gateway_id             = aws_internet_gateway.${var.instanceName}_igw.id
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "${var.instanceName}_rt_association" {
  subnet_id      = aws_subnet.${var.instanceName}_subnet-1.id
  route_table_id = aws_route_table.${var.instanceName}_rt-1.id
}
