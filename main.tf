resource "ibm_is_security_group_rule" "default_vpc_rule" {
  for_each  = local.all_rules_map
  group     = var.security_group_id
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
  security_group_rule_object = {
    for rule in var.security_group_rules :
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
      [
        for rule in local.ibm_cloud_internal_rules :
        rule if sec_rule.add_ibm_cloud_internal_rules == true
      ],
      [sec_rule]
    )
  }

  # extract merged rules and
  # create a map with rule name as key and rule as value
  all_rules_map = {
    for rule in flatten([
      for key, value in local.all_rules : value
    ]) :
    rule.name => rule
  }
}
