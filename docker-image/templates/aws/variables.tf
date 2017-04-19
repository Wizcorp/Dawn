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
variable "cidr_blocks" {
  type = "map"
}

# Nodes configuration
variable "nodes" {
  type = "map"
}