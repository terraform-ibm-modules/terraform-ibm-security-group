############################################################################
# Locals
############################################################################

locals {
  # IaaS and PaaS Rules
  ibm_cloud_internal_rules = [
    {
      name       = "ibmflow-iaas-outbound"
      direction  = "outbound"
      remote     = "161.26.0.0/16"
      local      = null
      ip_version = null
      protocol   = null
      port_min   = null
      port_max   = null
      type       = null
      code       = null
    },
    {
      name       = "ibmflow-iaas-inbound"
      direction  = "inbound"
      remote     = "161.26.0.0/16"
      local      = null
      ip_version = null
      protocol   = null
      port_min   = null
      port_max   = null
      type       = null
      code       = null
    },
    {
      name       = "ibmflow-paas-outbound"
      direction  = "outbound"
      remote     = "166.8.0.0/14"
      local      = null
      ip_version = null
      protocol   = null
      port_min   = null
      port_max   = null
      type       = null
      code       = null
    },
    {
      name       = "ibmflow-paas-inbound"
      direction  = "inbound"
      remote     = "166.8.0.0/14"
      local      = null
      ip_version = null
      protocol   = null
      port_min   = null
      port_max   = null
      type       = null
      code       = null
    }
  ]

  # add default names for customer rules when not provided, then concatenate IBM internal rules if requested
  all_rules = concat([
    for index, rule in var.security_group_rules :
    merge(rule, {
      name = rule.name != null ? rule.name : "rule-${index}"
    })
  ], var.add_ibm_cloud_internal_rules ? local.ibm_cloud_internal_rules : [])
}

############################################################################

############################################################################
# Security Group
# (if var.existing_security_group_name is null, create a new security group
# with name = var.security_group_name)
############################################################################

resource "ibm_is_security_group" "sg" {
  count          = var.use_existing_security_group || var.use_existing_security_group_id ? 0 : 1
  name           = var.security_group_name
  vpc            = var.vpc_id
  resource_group = var.resource_group
  access_tags    = var.access_tags
  tags           = var.tags
}

data "ibm_is_security_group" "existing_sg" {
  count = var.use_existing_security_group ? 1 : 0
  name  = var.existing_security_group_name
}

############################################################################

############################################################################
# Security Group Locals
############################################################################

locals {
  sg_id = var.existing_security_group_id != null ? var.existing_security_group_id : (var.existing_security_group_name != null ? data.ibm_is_security_group.existing_sg[0].id : ibm_is_security_group.sg[0].id)
}

############################################################################

#############################################################################
# Security Group Target
#############################################################################

resource "ibm_is_security_group_target" "sg_target" {
  count          = length(var.target_ids)
  security_group = local.sg_id
  target         = var.target_ids[count.index]
}

#############################################################################

##############################################################################
# Create Rules
##############################################################################

resource "ibm_is_security_group_rule" "security_group_rule" {
  for_each = {
    for rule in local.all_rules :
    (rule.name) => rule
  }
  group      = local.sg_id
  direction  = each.value.direction
  remote     = each.value.remote
  local      = each.value.local
  ip_version = each.value.ip_version
  name       = each.value.name

  # Use top-level protocol arguments instead of deprecated nested blocks
  protocol = each.value.protocol
  port_min = each.value.port_min
  port_max = each.value.port_max
  type     = each.value.type
  code     = each.value.code
}

##############################################################################
