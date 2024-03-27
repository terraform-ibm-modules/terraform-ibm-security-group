##############################################################################
# Resource Group
# (if var.resource_group is null, create a new RG using var.prefix)
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create new VPC
# (if var.vpc_id is null, create a new VPC)
##############################################################################

module "vpc" {
  count             = var.vpc_id != null ? 0 : 1
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "7.13.2"
  resource_group_id = module.resource_group.resource_group_id
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
  vpc                      = module.vpc[0].vpc_id
  zone                     = var.zone
  total_ipv4_address_count = var.total_ipv4_address_count
  resource_group           = module.resource_group.resource_group_id
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
  resource_group               = module.resource_group.resource_group_id
  vpc_id                       = module.vpc[0].vpc_id
  target_ids                   = [ibm_is_lb.sg_lb.id]
  access_tags                  = var.access_tags
  tags                         = var.resource_tags
}
