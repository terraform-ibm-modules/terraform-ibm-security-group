############################################################################
# Locals
############################################################################

locals {
  sg_name_null_and_use_sg_true = var.existing_security_group_name == null && var.use_existing_security_group
  sg_name_set_and_use_sg_false = var.existing_security_group_name != null && !var.use_existing_security_group
  sg_id_null_and_use_sg_true   = var.existing_security_group_id == null && var.use_existing_security_group_id
  sg_id_set_and_use_sg_false   = var.existing_security_group_id != null && !var.use_existing_security_group_id
  no_sg_name_and_no_vpc_id     = (var.use_existing_security_group == false && var.vpc_id == null) || (var.use_existing_security_group_id == false && var.vpc_id == null)
  mutually_exclusive           = var.existing_security_group_name != null && var.existing_security_group_id != null

  validation_message = coalesce(
    local.sg_name_null_and_use_sg_true ? "existing_security_group_name must be set when use_existing_security_group is set." : null,
    local.sg_name_set_and_use_sg_false ? "use_existing_security_group must be set when existing_security_group_name is set." : null,
    local.sg_id_null_and_use_sg_true ? "existing_security_group_name must be set when use_existing_security_group is set." : null,
    local.sg_id_set_and_use_sg_false ? "use_existing_security_group must be set when existing_security_group_name is set." : null,
    local.no_sg_name_and_no_vpc_id ? "VPC ID is required when creating a new security group." : null,
    local.mutually_exclusive ? "existing_security_group_name and existing_security_group_id are mutually exclusive. Set either one or the other (or none)" :
    "Valid configuration."
  )

  # Use regex to force an error if validation_message is not "Valid configuration."
  # tflint-ignore: terraform_unused_declarations
  fail_execution = regex("Valid configuration.", local.validation_message)

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
  group     = local.sg_id
  direction = each.value.direction
  remote    = each.value.remote

  ##############################################################################
  # Dynamicaly create ICMP Block
  ##############################################################################

  dynamic "icmp" {

    # Runs a for each loop, if the rule block contains icmp, it looks through the block
    # Otherwise the list will be empty

    for_each = (
      # Only allow creation of icmp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      each.value.icmp == null
      ? []
      : length([
        for value in ["type", "code"] :
        true if lookup(each.value["icmp"], value, null) == null
      ]) == 2
      ? [] # if all values null empty array
      : [each.value]
    )
    # Conditianally add content if sg has icmp
    content {
      type = lookup(
        each.value["icmp"],
        "type",
        null
      )
      code = lookup(
        each.value["icmp"],
        "code",
        null
      )
    }
  }

  ##############################################################################

  ##############################################################################
  # Dynamically create TCP Block
  ##############################################################################

  dynamic "tcp" {

    # Runs a for each loop, if the rule block contains tcp, it looks through the block
    # Otherwise the list will be empty

    for_each = (
      # Only allow creation of tcp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      # the default behavior will be to set `null` `port_min` values to 1 if null
      # and `port_max` to 65535 if null
      each.value.tcp == null
      ? []
      : length([
        for value in ["port_min", "port_max"] :
        true if lookup(each.value["tcp"], value, null) == null
      ]) == 2
      ? [] # if all values null empty array
      : [each.value]
    )

    # Conditionally adds content if sg has tcp
    content {
      port_min = lookup(
        each.value["tcp"],
        "port_min",
        null
      )

      port_max = lookup(
        each.value["tcp"],
        "port_max",
        null
      )
    }
  }

  ##############################################################################

  ##############################################################################
  # Dynamically create UDP Block
  ##############################################################################

  dynamic "udp" {

    # Runs a for each loop, if the rule block contains udp, it looks through the block
    # Otherwise the list will be empty

    for_each = (
      # Only allow creation of udp rules if all of the keys are not null.
      # This allows the use of the optional variable in landing zone patterns
      # to convert to a single typed list by adding `null` as the value.
      # the default behavior will be to set `null` `port_min` values to 1 if null
      # and `port_max` to 65535 if null
      each.value.udp == null
      ? []
      : length([
        for value in ["port_min", "port_max"] :
        true if lookup(each.value["udp"], value, null) == null
      ]) == 2
      ? [] # if all values null empty array
      : [each.value]
    )

    # Conditionally adds content if sg has tcp
    content {
      port_min = lookup(
        each.value["udp"],
        "port_min",
        null
      )
      port_max = lookup(
        each.value["udp"],
        "port_max",
        null
      )
    }
  }

  ##############################################################################
}

##############################################################################
