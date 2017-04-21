# Region
region = "us-west-1"

# Availability zone
availability_zone = "us-west-1b"

# CIDR Block to assign to te VPC's network
cidr_blocks = {
  vpc     = "172.24.0.0/16"
  public  = "172.24.0.0/20"
  private = "172.24.16.0/20"
}

#
nodes = {
  edge_count         = 1
  edge_ami           = "ami-af4333cf"
  edge_ami_user      = "centos"
  edge_instance_type = "t2.small"

  control_count         = 1
  control_ami           = "ami-af4333cf"
  control_ami_user      = "centos"
  control_instance_type = "t2.medium"

  worker_count         = 2
  worker_ami           = "ami-af4333cf"
  worker_ami_user      = "centos"
  worker_instance_type = "t2.medium"

  storage_count         = 0
  storage_ami           = "ami-af4333cf"
  storage_ami_user      = "centos"
  storage_instance_type = "r3.large"
}

# The deploy public key (dynamically injected on environment creation).
