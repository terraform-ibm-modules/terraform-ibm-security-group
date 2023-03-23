##############################################################################
# Outputs
##############################################################################

output "security_group" {
  description = "Security Group created"
  value       = var.create_security_group == true ? ibm_is_security_group.sg[0] : data.ibm_is_security_group.existing_sg[0]
}

output "security_group_rules" {
  description = "Security group rules"
  value       = module.create_sgr_rule.security_group_rule
}
