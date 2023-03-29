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
  count             = var.vpc_id != null ? 0 : 1
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc.git?ref=v5.0.1"
  resource_group_id = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  region            = var.region
  prefix            = var.prefix
  name              = var.vpc_name
  tags              = var.resource_tags
}

##############################################################################
# Update security group
##############################################################################

module "create_sgr_rule" {
  source                = "../.."
  security_group_rules  = var.security_group_rules
  create_security_group = var.create_security_group
  resource_group        = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  vpc_id                = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
}
