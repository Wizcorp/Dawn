# Region
region = "us-west-1"

# Availability zone
availalability_zone = "us-west-1a"

# CIDR Block to assign to te VPC's network
cidr_block = "172.24.0.0/16"

#
nodes = {
  edge_count         = 1
  edge_ami           = "ami-2cade64c"
  edge_instance_type = "t2.small"

  control_count         = 1
  control_ami           = "ami-2cade64c"
  control_instance_type = "t2.medium"

  worker_count         = 2
  worker_ami           = "ami-2cade64c"
  worker_instance_type = "c4.large"

  storage_count         = 0
  storage_ami           = "ami-2cade64c"
  storage_instance_type = "r3.large"
}

# The deploy public key (dynamically injected on environment creation).

