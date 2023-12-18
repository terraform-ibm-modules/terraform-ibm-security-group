##############################################################################
# Resource Group
# (if var.resource_group is null, create a new RG using var.prefix)
##############################################################################

resource "ibm_resource_group" "resource_group" {
  count = var.resource_group != null ? 0 : 1
  name  = "${var.prefix}-rg"

}

data "ibm_resource_group" "existing_resource_group" {
  count = var.resource_group != null ? 1 : 0
  name  = var.resource_group
}

##############################################################################
# Create new VPC
# (if var.vpc_id is null, create a new VPC)
##############################################################################

module "vpc" {
  source               = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version              = "7.13.2"
  resource_group_id    = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  region               = var.region
  prefix               = var.prefix
  name                 = "vpc"
  clean_default_sg_acl = true
  tags                 = var.resource_tags
}

##############################################################################
# Lookup name of default SG (as an example)
##############################################################################
data "ibm_is_vpc" "vpc" {
  identifier = module.vpc.vpc_id
}

locals {
  name_of_sg_to_update = data.ibm_is_vpc.vpc.default_security_group_name
}


##############################################################################
# Add rules to existing security group
##############################################################################

module "add_rules_to_sg" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = true
  use_existing_security_group  = true
  existing_security_group_name = local.name_of_sg_to_update
  security_group_rules = [{
    name      = "allow-example-inbound"
    direction = "inbound"
    remote    = "192.0.2.0/24"
  }]
}
