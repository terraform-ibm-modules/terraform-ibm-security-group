##############################################################################
# Resource Group
# (if var.resource_group is null, create a new RG using var.prefix)
##############################################################################

resource "ibm_resource_group" "resource_group" {
  count = var.resource_group != null ? 0 : 1
  name  = "${var.prefix}-rg"

}

data "ibm_resource_group" "existing_resource_group" {
  count = var.resource_group != null ? 1 : 0
  name  = var.resource_group
}

#############################################################################
# Security Group
#############################################################################

data "ibm_is_security_group" "existing_sg" {
  count = var.create_security_group ? 0 : 1
  name  = var.security_group_id
}

resource "ibm_is_security_group" "sg" {
  count          = var.create_security_group ? 1 : 0
  name           = var.sg_name
  vpc            = var.vpc_id
  resource_group = var.resource_group != null ? data.ibm_resource_group.existing_resource_group[0].id : ibm_resource_group.resource_group[0].id
}

##############################################################################
# Update security group
##############################################################################

module "create_sgr_rule" {
  source               = "../.."
  security_group_rules = var.security_group_rules
  security_group_id    = var.create_security_group ? ibm_is_security_group.sg[0].id : data.ibm_is_security_group.existing_sg[0].id
}

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_vpc_id = var.vpc_id == null ? tobool("Please provide VPC ID to create the secruity group") : false
}
