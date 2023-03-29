############################################################################
# Security Group
############################################################################

resource "ibm_is_security_group" "sg" {
  count          = var.create_security_group ? 1 : 0
  name           = var.security_group_name
  vpc            = var.vpc_id
  resource_group = var.resource_group
}

#############################################################################
# Security Group Target
#############################################################################

resource "ibm_is_security_group_target" "sg_target" {
  count          = length(var.target_ids)
  security_group = var.create_security_group ? ibm_is_security_group.sg[0].id : var.security_group_id
  target         = var.target_ids[count.index]
}

#############################################################################
# Security Group Rule
#############################################################################

resource "ibm_is_security_group_rule" "security_group_rule" {
  for_each  = local.all_rules_map
  group     = var.create_security_group ? ibm_is_security_group.sg[0].id : var.security_group_id
  direction = each.value.direction
  remote    = each.value.remote

  dynamic "tcp" {

    # Only allow creation of tcp rules if all of the keys are not null.
    # if rules null
    for_each = (each.value.tcp == null
      # empty array
      ? []
      # otherwise loop through the block and include if all of the keys are not null.
      # the default behavior will be to set 'null' 'port_min' values to 1 if null
      # and 'port_max' to 65535 if null
    : length([for value in ["port_min", "port_max"] : true if lookup(each.value["tcp"], value, null) == null]) == 2 ? [] : [each.value])

    content {
      port_min = lookup(
        lookup(
          each.value,
          "tcp"
        ),
        "port_min",
        null
      )

      port_max = lookup(
        lookup(
          each.value,
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
    for_each = (each.value.udp == null
      # empty array
      ? []
      # otherwise loop through the block and include if all of the keys are not null.
      # the default behavior will be to set 'null' 'port_min' values to 1 if null
      # and 'port_max' to 65535 if null
    : length([for value in ["port_min", "port_max"] : true if lookup(each.value["udp"], value, null) == null]) == 2 ? [] : [each.value])

    content {
      port_min = lookup(
        lookup(
          each.value,
          "udp"
        ),
        "port_min",
        null
      )
      port_max = lookup(
        lookup(
          each.value,
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
    for_each = (each.value.icmp == null
      # empty array
      ? []
      # otherwise loop through the block and include if all of the keys are not null.
      # the default behavior will be to set 'null' 'type' values to 0 if null
      # and 'code' to 254 if null
    : length([for value in ["type", "code"] : true if lookup(each.value["icmp"], value, null) == null]) == 2 ? [] : [each.value])

    content {
      type = lookup(
        lookup(
          each.value,
          "icmp"
        ),
        "type",
        null
      )
      code = lookup(
        lookup(
          each.value,
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
  validate_vpc_id = var.create_security_group && var.vpc_id == null ? tobool("VPC ID is required when creating a new security group") : true

  security_group_rule_object = {
    for rule in var.security_group_rules :
    rule.name => rule
  }

  ibm_cloud_internal_rules_object = {
    for rule in local.ibm_cloud_internal_rules :
    rule.name => rule
  }

  # IaaS and PaaS Rules
  ibm_cloud_internal_rules = [
    {
      name      = "ibmflow-iaas-outbound"
      direction = "outbound"
      remote    = "161.26.0.0/16"
      tcp       = null
      udp       = null
      icmp      = null
    },
    {
      name      = "ibmflow-iaas-inbound"
      direction = "inbound"
      remote    = "161.26.0.0/16"
      tcp       = null
      udp       = null
      icmp      = null
    },
    {
      name      = "ibmflow-paas-outbound"
      direction = "outbound"
      remote    = "166.8.0.0/14"
      tcp       = null
      udp       = null
      icmp      = null
    },
    {
      name      = "ibmflow-paas-inbound"
      direction = "inbound"
      remote    = "166.8.0.0/14"
      tcp       = null
      udp       = null
      icmp      = null
    }
  ]

  # merge internal and customer provide sg rules depending on add_ibm_cloud_internal_rules
  # this creates a map with customer security group name as key and all merged rules are value
  all_rules = {
    for sec_rule in local.security_group_rule_object :
    sec_rule.name => concat(
      # These rules cannot be added in a conditional operator due to inconsistent typing
      # This will add all internal rules if the security group object has add_ibm_cloud_internal_rules set to true
      [
        for rule in local.ibm_cloud_internal_rules_object :
        rule if sec_rule.add_ibm_cloud_internal_rules == true
      ],
      [sec_rule]
    )
  }

  # extract distinct rules as add_ibm_cloud_internal_rules = true for every object in sg object may contain duplicates
  all_rules_values = distinct([for v in flatten(values(local.all_rules)) :
    merge({
      direction = v.direction, remote = v.remote, name = v.name,
      icmp      = v.icmp == null ? null : { code = v.icmp.code, type = v.icmp.type }
      tcp       = v.tcp == null ? null : { port_min = v.tcp.port_min, port_max = v.tcp.port_max }
      udp       = v.udp == null ? null : { port_min = v.udp.port_min, port_max = v.udp.port_max }

    })
  ])

  # extract merged rules and
  # create a map with rule name as key and rule as value
  all_rules_map = {
    for rule in local.all_rules_values :
    rule.name => rule
  }
}
