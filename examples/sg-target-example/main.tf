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
  version           = "7.11.0"
  resource_group_id = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  region            = var.region
  prefix            = var.prefix
  name              = var.vpc_name
  tags              = var.resource_tags
}

##############################################################################
# Create subnet
##############################################################################

resource "ibm_is_subnet" "subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  zone                     = var.zone
  total_ipv4_address_count = var.total_ipv4_address_count
  resource_group           = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
}

##############################################################################
# Create application load balancer
##############################################################################


resource "ibm_is_lb" "sg_lb" {
  name    = "${var.prefix}-load-balancer"
  subnets = [ibm_is_subnet.subnet.id]
  type    = "private"
}

##############################################################################
# Update security group
##############################################################################

module "create_sgr_rule" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = var.add_ibm_cloud_internal_rules
  security_group_name          = "${var.prefix}-target"
  security_group_rules         = var.security_group_rules
  resource_group               = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  vpc_id                       = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  target_ids                   = [ibm_is_lb.sg_lb.id]
}
