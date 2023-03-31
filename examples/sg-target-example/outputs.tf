##############################################################################
# Outputs
##############################################################################

output "security_group_rules" {
  description = "Security group rules"
  value       = module.create_sgr_rule.security_group_rule
}

output "security_target" {
  description = "Security group targets"
  value       = module.create_sgr_rule.security_target
}
