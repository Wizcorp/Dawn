#
# The following two variables should be injected
# by the container itself; however, if desired (mostly
# in cases where you would want to run terraform locally
# instead of through the container), you may want to specify
# a value for those in the terraform.tfvars file
#
variable "project_name" {}

variable "project_environment" {}

variable "deploy_pubkey" {}

###
# AWS Configuration
###
#
# The following is expected to be present:
#
#    export AWS_ACCESS_KEY_ID="anaccesskey"
#    export AWS_SECRET_ACCESS_KEY="asecretkey"
#
variable "region" {}

# Which availability zone to target
variable "availability_zone" {}

# Configuration for the VPC
variable "cidr_block" {
  default = "172.24.0.0/16"
}

# Nodes configuration
variable "nodes" {
  type = "map"
}

# Provider definition
provider "aws" {
  region = "${var.region}"
}

# We will be creating our own key pair to use
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-${var.project_environment}-deploykey"
  public_key = "${var.deploy_pubkey}"
}

###
# VPC description
###
data "aws_vpc" "default" {}

# Subnet
resource "aws_subnet" "default" {
  vpc_id            = "${data.aws_vpc.default.id}"
  availability_zone = "${var.availability_zone}"
  cidr_block        = "${var.cidr_block}"

  tags {
    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

# Internet accessibility for machines within the VPC
resource "aws_internet_gateway" "default" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags {
    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

# Allow SSH and ping on all machines
resource "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Intra-cluster communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block}"]
  }

  # Ping
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

# Additionally add HTTP/S to the edges
resource "aws_security_group" "edge" {
  vpc_id = "${data.aws_vpc.default.id}"

  #  HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

###
# Edge node description
###
resource "aws_instance" "edge" {
  count                       = "${var.nodes["edge_count"]}"
  ami                         = "${var.nodes["edge_ami"]}"
  key_name                    = "${aws_key_pair.deployer.key_name}"
  instance_type               = "${var.nodes["edge_instance_type"]}"
  subnet_id                   = "${data.aws_subnet.default.id}"
  vpc_security_group_ids      = ["${aws_security_group.default.id}", "${aws_security_group.edge.id}"]
  associate_public_ip_address = true

  tags {
    Name        = "${var.project_name}.${var.project_environment}.edge-${count.index + 1}"
    project     = "${var.project_name}"
    environment = "${var.project_environment}"
    role        = "edge"
    sshUser     = "ec2-user"
  }
}

resource "aws_eip" "edge" {
  instance = "${aws_instance.edge.id}"
  vpc      = true
}

###
# Control node description
###
resource "aws_instance" "control" {
  count                  = "${var.nodes["control_count"]}"
  ami                    = "${var.nodes["control_ami"]}"
  key_name               = "${aws_key_pair.deployer.key_name}"
  instance_type          = "${var.nodes["control_instance_type"]}"
  subnet_id              = "${data.aws_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  tags {
    Name         = "${var.project_name}.${var.project_environment}.control-${count.index + 1}"
    project      = "${var.project_name}"
    environment  = "${var.project_environment}"
    roles        = "control"
    sshUser      = "ec2-user"
    sshExtraArgs = "ssh -W %h:%p ${aws_eip.edge.public_ip}"
  }
}

###
# Worker node description
###
resource "aws_instance" "worker" {
  count                  = "${var.nodes["worker_count"]}"
  ami                    = "${var.nodes["worker_ami"]}"
  key_name               = "${aws_key_pair.deployer.key_name}"
  instance_type          = "${var.nodes["worker_instance_type"]}"
  subnet_id              = "${data.aws_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  tags {
    Name         = "${var.project_name}.${var.project_environment}.worker-${count.index + 1}"
    project      = "${var.project_name}"
    environment  = "${var.project_environment}"
    role         = "worker"
    sshUser      = "ec2-user"
    sshExtraArgs = "ssh -W %h:%p ${aws_eip.edge.public_ip}"
  }
}

###
# Storage node description
###
resource "aws_instance" "storage" {
  count                  = "${var.nodes["storage_count"]}"
  ami                    = "${var.nodes["storage_ami"]}"
  key_name               = "${aws_key_pair.deployer.key_name}"
  instance_type          = "${var.nodes["storage_instance_type"]}"
  subnet_id              = "${data.aws_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  tags {
    Name         = "${var.project_name}.${var.project_environment}.storage-${count.index + 1}"
    project      = "${var.project_name}"
    environment  = "${var.project_environment}"
    role         = "storage"
    sshUser      = "ec2-user"
    sshExtraArgs = "ssh -W %h:%p ${aws_eip.edge.public_ip}"
  }
}
