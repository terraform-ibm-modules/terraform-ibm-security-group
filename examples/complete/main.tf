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
# (if var.vpc_id is null, create a new VPCs using var.prefix)
##############################################################################

resource "ibm_is_vpc" "vpc" {
  count                       = var.vpc_id != null ? 0 : 1
  name                        = "${var.prefix}-vpc"
  resource_group              = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  classic_access              = var.classic_access
  address_prefix_management   = var.use_manual_address_prefixes == false ? null : "manual"
  default_network_acl_name    = var.default_network_acl_name
  default_security_group_name = var.default_security_group_name
  default_routing_table_name  = var.default_routing_table_name
  tags                        = var.resource_tags
}

data "ibm_is_vpc" "existing_vpc" {
  count = var.vpc_id != null ? 1 : 0
  name  = var.vpc_id
}

##############################################################################
# Update security group
##############################################################################

module "create_sgr_rule" {
  source                = "../.."
  security_group_rules  = var.security_group_rules
  create_security_group = var.create_security_group
  resource_group        = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  vpc_id                = var.vpc_id != null ? data.ibm_is_vpc.existing_vpc[0].id : ibm_is_vpc.vpc[0].id
}
