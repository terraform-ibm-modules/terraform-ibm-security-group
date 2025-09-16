##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.3.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create new VPC
# (if var.vpc_id is null, create a new VPC)
##############################################################################

module "vpc" {
  source               = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version              = "8.3.0"
  resource_group_id    = module.resource_group.resource_group_id
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
    name       = "allow-example-inbound"
    direction  = "inbound"
    remote     = "192.0.2.0/24"
    local      = "0.0.0.0/0"
    ip_version = "ipv4"
  }]
  access_tags = var.access_tags
  tags        = var.resource_tags
}
