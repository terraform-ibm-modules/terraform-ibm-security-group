# ##############################################################################
# # Outputs
# ##############################################################################

output "resource_group" {
  description = "Resource group created"
  value       = module.resource_group.resource_group_id
}

output "security_group_id_0" {
  description = "The ID of the security group 0"
  value       = module.create_sgr0.security_group_id
}

output "security_group_rules_0" {
  description = "The security group rules created for security group 0"
  value       = module.create_sgr0_rules.security_group_rules
}

output "security_group_id_1" {
  description = "The ID of the security group 1"
  value       = module.create_sgr1.security_group_id
}

output "security_group_rules_1" {
  description = "The security group rules created for security group 1"
  value       = module.create_sgr1_rules.security_group_rules
}

output "security_group_id_2" {
  description = "The ID of the security group 2"
  value       = module.create_sgr2.security_group_id
}

output "security_group_rules_2" {
  description = "The security group rules created for security group 2"
  value       = module.create_sgr2_rules.security_group_rules
}
