# Provider definition
provider "aws" {
  region = "${var.region}"
}

# We will be creating our own key pair to use
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-${var.project_environment}-deploykey"
  public_key = "${var.deploy_pubkey}"
}
