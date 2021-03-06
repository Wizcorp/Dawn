# Allow SSH and ping on all machines
resource "aws_security_group" "internal" {
  vpc_id = "${aws_vpc.main.id}"

  # Intra-cluster communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_blocks["vpc"]}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_blocks["vpc"]}"]
  }

  tags {
    Name = "Internal Security Group"

    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}

# Used by machines on the private network to access external resources
resource "aws_security_group" "external_access" {
  name = "Expose HTTP/HTTPs"
  description = "Allows instances to talk over HTTP and HTTPS"
  vpc_id = "${aws_vpc.main.id}"

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

  # NTP requests
  egress {
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  # Teleport
  ingress {
    from_port   = 3022
    to_port     = 3026
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  egress {
    from_port   = 3022
    to_port     = 3026
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  # Docker
  ingress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  egress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  # Traefik dashboard
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  # Consul UI
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  egress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = "${var.secure_access_whitelist}"
  }

  # Send email
  egress {
    from_port   = 587
    to_port     = 587
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "Internet Access"

    project     = "${var.project_name}"
    environment = "${var.project_environment}"
  }
}
