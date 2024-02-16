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
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "7.13.2"
  resource_group_id = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  region            = var.region
  prefix            = var.prefix
  name              = var.vpc_name
  tags              = var.resource_tags
}

##############################################################################
# Create security groups for demonstration purposes in this example
##############################################################################

# Create a first security group with client security_group_rules + rules for internal ibm flows
module "security_group_1" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = var.add_ibm_cloud_internal_rules
  security_group_name          = "${var.prefix}-1"
  security_group_rules         = var.security_group_rules
  resource_group               = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  vpc_id                       = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  access_tags                  = var.access_tags
  tags                         = var.resource_tags
}

# Create a second security group that reference the first security group (inbound) + (optionally) rules for internal ibm flows
module "security_group_2" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = var.add_ibm_cloud_internal_rules
  security_group_name          = "${var.prefix}-2"
  # sg rule referencing a security group
  security_group_rules = [{
    name      = "allow-all-inbound-sg"
    direction = "inbound"
    remote    = module.security_group_1.security_group_id
  }]
  resource_group = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  vpc_id         = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  access_tags    = var.access_tags
  tags           = var.resource_tags
}
