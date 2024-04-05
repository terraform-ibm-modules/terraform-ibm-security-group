##############################################################################
# Outputs
##############################################################################

output "resource_group" {
  description = "Resource group created"
  value       = module.resource_group.resource_group_id
}

output "vpc_id" {
  description = "VPC where the security group rules are created"
  value       = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
}

output "security_group_rules" {
  description = "Security group rules created"
  value       = module.create_sgr_rule.security_group_rule
}

output "security_group_id" {
  description = "The ID of the security group where the rules are added"
  value       = module.create_sgr_rule.security_group_id
}

output "security_group_rules_with_existing_sg" {
  description = "Security group rules created with existing security group"
  value       = module.create_sgr_rule1.security_group_rule
}
