
##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create new VPC
# (if var.vpc_id is null, create a new VPC)
##############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "8.9.1"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
  tags              = var.resource_tags
}

##############################################################################
# Update security group
##############################################################################

locals {
  # some various types of typical rules
  sg_rules = [{
    name      = "allow-all-inbound"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    }, {
    name      = "sgr-tcp"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    tcp = {
      port_min = 8080
      port_max = 8080
    }
    }, {
    name      = "sgr-udp"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    udp = {
      port_min = 805
      port_max = 807
    }
    }, {
    name      = "sgr-icmp"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    icmp = {
      code = 20
      type = 30
    }
  }]
}

# Main example of wide range of basic rules
module "create_sgr_rule" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = var.add_ibm_cloud_internal_rules
  security_group_name          = "${var.prefix}-1"
  security_group_rules         = local.sg_rules
  resource_group               = module.resource_group.resource_group_id
  vpc_id                       = module.vpc.vpc_id
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
  resource_group = module.resource_group.resource_group_id
  vpc_id         = module.vpc.vpc_id
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
  resource_group = module.resource_group.resource_group_id
  vpc_id         = module.vpc.vpc_id
  access_tags    = var.access_tags
  tags           = var.resource_tags
}
