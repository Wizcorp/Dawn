###
# VPC description
###
resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_blocks["vpc"]}"

  tags {
    Name = "VPC for ${var.project_name} (${var.project_environment})"
  }
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${var.availability_zone}"
  cidr_block        = "${var.cidr_blocks["public"]}"

  tags {
    Name        = "Public Subnet for ${var.project_name} (${var.project_environment})"

    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${var.availability_zone}"
  cidr_block        = "${var.cidr_blocks["private"]}"

  tags {
    Name        = "Private Subnet for ${var.project_name} (${var.project_environment})"

    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

# Internet accessibility for machines within the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "Main Internet Gateway"

    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

# We need a NAT gateway to give access to the internet to machines on the private
# subnet
resource "aws_eip" "nat" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"

  depends_on = ["aws_internet_gateway.main"]
}

# This is the public subnet's route table, it uses the IGW directly
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name        = "Public Route Table"

    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

# This is the public subnet's route table, it uses the IGW directly
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name        = "Private Subnet Route Table"

    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

# Finally assign each table to each subnet
resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}