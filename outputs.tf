##############################################################################
# Outputs
##############################################################################

output "security_target" {
  description = "Resources added to the security group"
  value       = ibm_is_security_group_target.sg_target
}

output "security_group_id" {
  description = "The ID of the security group where the rules are added"
  value       = local.sg_id

  depends_on = [ibm_is_security_group_rule.security_group_rule]
}

output "security_group_rule" {
  description = "Security group rules"
  value       = ibm_is_security_group_rule.security_group_rule
}

##############################################################################