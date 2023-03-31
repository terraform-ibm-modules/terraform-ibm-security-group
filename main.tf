############################################################################
# Security Group
# (if var.existing_security_group_name is null, create a new security group
# with name = var.security_group_name)
############################################################################

resource "ibm_is_security_group" "sg" {
  count          = var.existing_security_group_name == null ? 1 : 0
  name           = var.security_group_name
  vpc            = var.vpc_id
  resource_group = var.resource_group
}

data "ibm_is_security_group" "existing_sg" {
  count = var.existing_security_group_name == null ? 0 : 1
  name  = var.existing_security_group_name
}


#############################################################################
# Security Group Target
#############################################################################

resource "ibm_is_security_group_target" "sg_target" {
  count          = length(var.target_ids)
  security_group = var.existing_security_group_name != null ? data.ibm_is_security_group.existing_sg[0].id : ibm_is_security_group.sg[0].id
  target         = var.target_ids[count.index]
}

#############################################################################
# Security Group Rule
#############################################################################

resource "ibm_is_security_group_rule" "security_group_rule" {
  count     = length(local.all_rules)
  group     = var.existing_security_group_name != null ? data.ibm_is_security_group.existing_sg[0].id : ibm_is_security_group.sg[0].id
  direction = local.all_rules[count.index].direction
  remote    = local.all_rules[count.index].remote

  dynamic "tcp" {

    # Only allow creation of tcp rules if all of the keys are not null.
    # if rules null
    for_each = (local.all_rules[count.index].tcp == null
      # empty array
      ? []
      # otherwise loop through the block and include if all of the keys are not null.
      # the default behavior will be to set 'null' 'port_min' values to 1 if null
      # and 'port_max' to 65535 if null
    : length([for value in ["port_min", "port_max"] : true if lookup(local.all_rules[count.index]["tcp"], value, null) == null]) == 2 ? [] : [local.all_rules[count.index]])

    content {
      port_min = lookup(
        lookup(
          local.all_rules[count.index],
          "tcp"
        ),
        "port_min",
        null
      )

      port_max = lookup(
        lookup(
          local.all_rules[count.index],
          "tcp"
        ),
        "port_max",
        null
      )
    }
  }

  dynamic "udp" {

    # Only allow creation of udp rules if all of the keys are not null.
    # if rules null
    for_each = (local.all_rules[count.index].udp == null
      # empty array
      ? []
      # otherwise loop through the block and include if all of the keys are not null.
      # the default behavior will be to set 'null' 'port_min' values to 1 if null
      # and 'port_max' to 65535 if null
    : length([for value in ["port_min", "port_max"] : true if lookup(local.all_rules[count.index]["udp"], value, null) == null]) == 2 ? [] : [local.all_rules[count.index]])

    content {
      port_min = lookup(
        lookup(
          local.all_rules[count.index],
          "udp"
        ),
        "port_min",
        null
      )
      port_max = lookup(
        lookup(
          local.all_rules[count.index],
          "udp"
        ),
        "port_max",
        null
      )
    }
  }

  dynamic "icmp" {
    # Only allow creation of icmp rules if all of the keys are not null.
    # if rules null
    for_each = (local.all_rules[count.index].icmp == null
      # empty array
      ? []
      # otherwise loop through the block and include if all of the keys are not null.
      # the default behavior will be to set 'null' 'type' values to 0 if null
      # and 'code' to 254 if null
    : length([for value in ["type", "code"] : true if lookup(local.all_rules[count.index]["icmp"], value, null) == null]) == 2 ? [] : [local.all_rules[count.index]])

    content {
      type = lookup(
        lookup(
          local.all_rules[count.index],
          "icmp"
        ),
        "type",
        null
      )
      code = lookup(
        lookup(
          local.all_rules[count.index],
          "icmp"
        ),
        "code",
        null
      )
    }
  }
}

locals {

  # tflint-ignore: terraform_unused_declarations
  validate_vpc_id = var.existing_security_group_name == null && var.vpc_id == null ? tobool("VPC ID is required when creating a new security group") : true

  # IaaS and PaaS Rules
  ibm_cloud_internal_rules = [
    {
      name      = "ibmflow-iaas-outbound"
      direction = "outbound"
      remote    = "161.26.0.0/16"
      tcp       = {}
      udp       = {}
      icmp      = {}
    },
    {
      name      = "ibmflow-iaas-inbound"
      direction = "inbound"
      remote    = "161.26.0.0/16"
      tcp       = {}
      udp       = {}
      icmp      = {}
    },
    {
      name      = "ibmflow-paas-outbound"
      direction = "outbound"
      remote    = "166.8.0.0/14"
      tcp       = {}
      udp       = {}
      icmp      = {}
    },
    {
      name      = "ibmflow-paas-inbound"
      direction = "inbound"
      remote    = "166.8.0.0/14"
      tcp       = {}
      udp       = {}
      icmp      = {}
    }
  ]

  # concatenate IBM internal rules and customer security group rules depending on add_ibm_cloud_internal_rules
  all_rules = concat(var.security_group_rules, var.add_ibm_cloud_internal_rules ? local.ibm_cloud_internal_rules : [])
}
