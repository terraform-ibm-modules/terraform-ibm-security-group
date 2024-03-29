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
# Update security group
##############################################################################

# Main example of wide range of basic rules
module "create_sgr_rule" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = var.add_ibm_cloud_internal_rules
  security_group_name          = "${var.prefix}-1"
  security_group_rules         = var.security_group_rules
  resource_group               = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  vpc_id                       = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  access_tags                  = var.access_tags
  tags                         = var.resource_tags
}

# Example of creating new SG and rule, with the rule allowing access from another existing security group
module "create_sgr_rule1" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = var.add_ibm_cloud_internal_rules
  security_group_name          = "${var.prefix}-2"
  # sg rule referencing a security group
  security_group_rules = [{
    name      = "allow-all-inbound-sg"
    direction = "inbound"
    remote    = module.create_sgr_rule.security_group_id
  }]
  resource_group = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  vpc_id         = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  access_tags    = var.access_tags
  tags           = var.resource_tags
}

# Example of new SG and rule, with the rule referencing the same SG that was created (self-reference)
module "create_sgr_rule2" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = var.add_ibm_cloud_internal_rules
  security_group_name          = "${var.prefix}-3"
  # sg rule referencing its own parent sg
  security_group_rules = [{
    name      = "allow-all-inbound-same-sg"
    direction = "inbound"
    remote    = module.create_sgr_rule2.security_group_id_for_ref
  }]
  resource_group = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  vpc_id         = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  access_tags    = var.access_tags
  tags           = var.resource_tags
}
