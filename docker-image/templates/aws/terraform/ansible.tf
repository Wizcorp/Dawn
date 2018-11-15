resource "ansible_group" "all" {
  inventory_group_name  = "all"
  children              = ["docker"]
  vars {
    ansible_ssh_private_key_file = "/home/dawn/.ssh/deploy"
    ansible_host_key_checking    = "false"
    local_domain_name            = "${var.domain}"
    smtp_hostname                = "email-smtp.${var.ses_region}.amazonaws.com"
    smtp_port                    = "587"
    smtp_username                = "${aws_iam_access_key.smtp.id}"
    smtp_password                = "${aws_iam_access_key.smtp.ses_smtp_password}"
  }
}

resource "ansible_group" "ssh-proxied" {
  inventory_group_name = "ssh-proxied"

  vars {
    ansible_ssh_extra_args       = "-o ProxyCommand='ssh -l ${var.nodes["edge_ami_user"]} -i ~/.ssh/deploy -W %h:%p -q ${aws_eip.edge.public_ip}'"
  }
}

resource "ansible_group" "docker" {
  inventory_group_name  = "docker"
  children              = ["swarm"]
}

resource "ansible_group" "swarm" {
  inventory_group_name = "swarm"
  children              = ["consul", "monitor", "control", "edge", "worker"]
}

resource "ansible_group" "monitor" {
  inventory_group_name = "monitor"
}

resource "ansible_group" "control" {
  inventory_group_name = "control"
}

resource "ansible_group" "edge" {
  inventory_group_name = "edge"
}

resource "ansible_host" "edge" {
  count               = "${var.nodes["edge_count"]}"
  inventory_hostname  = "${var.project_name}-${var.project_environment}-edge-${count.index}"
  groups              = ["edge"]
  vars {
    ansible_user      = "${var.nodes["edge_ami_user"]}"
    ansible_host      = "${element(aws_eip.edge.*.public_ip, count.index)}"
  }
}

resource "ansible_host" "control_and_monitor" {
  count               = "${var.nodes["control_count"]}"
  inventory_hostname  = "${var.project_name}-${var.project_environment}-control-${count.index}"
  groups              = ["control", "monitor", "ssh-proxied"]
  vars {
    ansible_user      = "${var.nodes["control_ami_user"]}"
    ansible_host      = "${element(aws_instance.control.*.private_ip, count.index)}"

    // The following variables will be used by gitlab-runner
    mysql_host        = "${aws_rds_cluster.aurora.endpoint}"
    mysql_db          = "${aws_rds_cluster.aurora.database_name}"
    mysql_user        = "${aws_rds_cluster.aurora.master_username}"
    mysql_pass        = "${aws_rds_cluster.aurora.master_password}"
    redis_host        = "${aws_elasticache_cluster.redis.cache_nodes.0.address}"

  }
}

resource "ansible_host" "worker" {
  count               = "${var.nodes["worker_count"]}"
  inventory_hostname  = "${var.project_name}-${var.project_environment}-worker-${count.index}"
  groups              = ["worker", "ssh-proxied"]
  vars {
    ansible_user      = "${var.nodes["worker_ami_user"]}"
    ansible_host      = "${element(aws_instance.worker.*.private_ip, count.index)}"
  }
}
