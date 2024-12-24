############################################################################
# Locals
############################################################################

locals {
  sg_name_null_and_use_sg_true = var.existing_security_group_name == null && var.use_existing_security_group
  sg_name_set_and_use_sg_false = var.existing_security_group_name != null && !var.use_existing_security_group
  sg_id_null_and_use_sg_true   = var.existing_security_group_id == null && var.use_existing_security_group_id
  sg_id_set_and_use_sg_false   = var.existing_security_group_id != null && !var.use_existing_security_group_id
  no_sg_name_and_no_vpc_id     = var.use_existing_security_group == false && var.use_existing_security_group_id == false && var.vpc_id == null
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
