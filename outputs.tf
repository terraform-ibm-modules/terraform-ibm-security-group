##############################################################################
# Outputs
##############################################################################

output "security_target" {
  description = "Security targets attached"
  value       = ibm_is_security_group_target.sg_target
}

output "security_group_rule" {
  description = "Security group rules"
  value       = ibm_is_security_group_rule.security_group_rule
}
