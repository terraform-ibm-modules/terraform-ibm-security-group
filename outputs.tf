##############################################################################
# Outputs
##############################################################################

output "security_group_rule" {
  description = "Security group rules"
  value       = ibm_is_security_group_rule.default_vpc_rule
}
