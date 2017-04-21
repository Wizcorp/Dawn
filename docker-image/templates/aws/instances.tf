###
# Edge node description
###
resource "aws_instance" "edge" {
  count                       = "${var.nodes["edge_count"]}"
  ami                         = "${var.nodes["edge_ami"]}"
  key_name                    = "${aws_key_pair.deployer.key_name}"
  instance_type               = "${var.nodes["edge_instance_type"]}"
  subnet_id                   = "${aws_subnet.public.id}"
  vpc_security_group_ids      = [
    "${aws_security_group.external_access.id}",
    "${aws_security_group.internal.id}"
  ]
  associate_public_ip_address = true
  private_ip                  = "${cidrhost(var.cidr_blocks["public"], 5 + count.index)}"

  tags {
    Name        = "${var.project_name}.${var.project_environment}.edge-${count.index + 1}"
    project     = "${var.project_name}"
    environment = "${var.project_environment}"
    roles       = "edge"
    sshUser     = "${var.nodes["edge_ami_user"]}"
    dockerType  = "edge"
  }
}

resource "aws_eip" "edge" {
  count = "${var.nodes["edge_count"]}"

  instance = "${element(aws_instance.edge.*.id, count.index)}"
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
  subnet_id              = "${aws_subnet.private.id}"
  vpc_security_group_ids = [
    "${aws_security_group.external_access.id}",
    "${aws_security_group.internal.id}"
  ]
  private_ip             = "${cidrhost(var.cidr_blocks["private"], 5 + count.index)}"

  tags {
    Name         = "${var.project_name}.${var.project_environment}.control-${count.index + 1}"
    project      = "${var.project_name}"
    environment  = "${var.project_environment}"
    roles        = "control,monitor"
    sshUser      = "${var.nodes["control_ami_user"]}"
    sshExtraArgs = "ssh -W %h:%p ${aws_eip.edge.public_ip}"
    dockerType   = "control"
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
  subnet_id              = "${aws_subnet.private.id}"
  vpc_security_group_ids = [
    "${aws_security_group.external_access.id}",
    "${aws_security_group.internal.id}"
  ]
  private_ip             = "${cidrhost(var.cidr_blocks["private"], 50 + count.index)}"

  tags {
    Name         = "${var.project_name}.${var.project_environment}.worker-${count.index + 1}"
    project      = "${var.project_name}"
    environment  = "${var.project_environment}"
    roles        = "worker"
    sshUser      = "${var.nodes["worker_ami_user"]}"
    sshExtraArgs = "ssh -W %h:%p ${aws_eip.edge.public_ip}"
    dockerType   = "worker"
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
  subnet_id              = "${aws_subnet.private.id}"
  vpc_security_group_ids = [
    "${aws_security_group.external_access.id}",
    "${aws_security_group.internal.id}"
  ]
  private_ip             = "${cidrhost(var.cidr_blocks["private"], 150 + count.index)}"

  tags {
    Name         = "${var.project_name}.${var.project_environment}.storage-${count.index + 1}"
    project      = "${var.project_name}"
    environment  = "${var.project_environment}"
    roles        = "storage"
    sshUser      = "${var.nodes["storage_ami_user"]}"
    sshExtraArgs = "-o ProxyCommand='ssh -l ${var.nodes["edge_ami_user"]} -i ~/.ssh/deploy -W %h:%p -q ${aws_eip.edge.public_ip}'"
    dockerType   = "worker"
  }
}
