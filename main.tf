resource "ibm_is_security_group_rule" "default_vpc_rule" {
  for_each  = local.security_group_rule_object
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
}
