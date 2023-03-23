##############################################################################
# Security Group Rules
##############################################################################

locals {
  # Internal IBM IPs
  ibm_internal_sg_rules = [
    {
      name      = "${var.prefix}-egress-1"
      direction = "outbound"
      remote    = "161.26.0.0/16"
      tcp       = null
      udp       = null
      icmp      = null
    },
    {
      name      = "${var.prefix}-ingress-1"
      direction = "inbound"
      remote    = "161.26.0.0/16"
      tcp       = null
      udp       = null
      icmp      = null
    },
    {
      name      = "${var.prefix}-egress-2"
      direction = "outbound"
      remote    = "166.8.0.0/14"
      tcp       = null
      udp       = null
      icmp      = null
    },
    {
      name      = "${var.prefix}-ingress-2"
      direction = "inbound"
      remote    = "166.8.0.0/14"
      tcp       = null
      udp       = null
      icmp      = null
    }
  ]

  # create a map for customer provided sg rules
  security_group_rule_object = {
    for rule in var.security_group_rules :
    rule.name => rule
  }

  # create a map for internal IBM IPs
  ibm_internal_sg_rules_object = {
    for rule in local.ibm_internal_sg_rules :
    rule.name => rule
  }

  # merge internal and customer provide sg rules depending on add_ibm_internal_sg_rules and prepend_ibm_rules
  all_rules = merge(
    local.ibm_internal_sg_rules_object,
    { for name, rule in local.security_group_rule_object :
      name => rule.add_ibm_internal_sg_rules && rule.prepend_ibm_rules ?
      merge(
        try(local.ibm_internal_sg_rules_object[name], {}),
        { name      = rule.name,
          direction = rule.direction,
          remote    = rule.remote,
          tcp       = rule.tcp,
          udp       = rule.udp,
          icmp      = rule.icmp
        }
      ) :
      rule.add_ibm_internal_sg_rules && !rule.prepend_ibm_rules ?
      {
        name      = rule.name,
        direction = rule.direction,
        remote    = rule.remote,
        tcp       = rule.tcp,
        udp       = rule.udp,
        icmp      = rule.icmp,
      } :
      {
        name      = rule.name,
        direction = rule.direction,
        remote    = rule.remote,
        tcp       = rule.tcp,
        udp       = rule.udp,
        icmp      = rule.icmp,
      }
    }
  )
}

##############################################################################
# Resource Group
# (if var.resource_group is null, create a new RG using var.prefix)
##############################################################################

resource "ibm_resource_group" "resource_group" {
  count    = var.resource_group != null ? 0 : 1
  name     = "${var.prefix}-rg"
  quota_id = null
}

data "ibm_resource_group" "existing_resource_group" {
  count = var.resource_group != null ? 1 : 0
  name  = var.resource_group
}

##############################################################################
# Create new VPC
# (if var.vpc_name is null, create a new VPCs using var.prefix and var.name)
##############################################################################

resource "ibm_is_vpc" "vpc" {
  count                       = var.vpc_name != null ? 0 : 1
  name                        = var.prefix != null ? "${var.prefix}-vpc" : "${var.vpc_name}-vpc"
  resource_group              = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
  classic_access              = var.classic_access
  address_prefix_management   = var.use_manual_address_prefixes == false ? null : "manual"
  default_network_acl_name    = var.default_network_acl_name
  default_security_group_name = var.default_security_group_name
  default_routing_table_name  = var.default_routing_table_name
  tags                        = var.resource_tags
}

data "ibm_is_vpc" "existing_vpc" {
  count = var.vpc_name != null ? 1 : 0
  name  = var.vpc_name

}

#############################################################################
# Update security group
#############################################################################

module "create_sgr_rule" {
  source               = "../.."
  security_group_rules = values(local.all_rules)
  security_group_id    = var.vpc_name != null ? data.ibm_is_vpc.existing_vpc[0].default_security_group : ibm_is_vpc.vpc[0].default_security_group
}
