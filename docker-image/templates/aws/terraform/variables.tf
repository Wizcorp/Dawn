#
# The following two variables should be injected
# by the container itself; however, if desired (mostly
# in cases where you would want to run terraform locally
# instead of through the container), you may want to specify
# a value for those in the terraform.tfvars file
#
variable "project_name" {}

variable "project_environment" {}

variable "domain" {}

variable "deploy_pubkey" {}

###
# AWS Configuration
###
variable "region" {}

variable "ses_region" {}

# Which availability zone to target
variable "availability_zone" {}

# Only whitelisted CIDRs are allowed to access sensitive services
variable "secure_access_whitelist" { default = [] }

# Configuration for the VPC
variable "cidr_blocks" {
  type = "map"
}

# Nodes configuration
variable "nodes" {
  type = "map"
}
