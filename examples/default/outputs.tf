##############################################################################
# Outputs
##############################################################################

output "resource_group" {
  description = "Resource group created"
  value       = var.resource_group != null ? data.ibm_resource_group.existing_resource_group : ibm_resource_group.resource_group
}

output "vpc" {
  description = "VPC where the security group rules are created"
  value       = var.vpc_id != null ? data.ibm_is_vpc.existing_vpc[0] : ibm_is_vpc.vpc[0]
}

output "security_group_rules" {
  description = "Security group rules created"
  value       = module.create_sgr_rule.security_group_rule
}
