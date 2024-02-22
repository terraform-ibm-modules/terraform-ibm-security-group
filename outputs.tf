##############################################################################
# Outputs
##############################################################################

output "security_target" {
  description = "Resources added to the security group"
  value       = ibm_is_security_group_target.sg_target
}

output "security_group_id" {
  description = "The ID of the security group where the rules are added. NOTE: This value will not be available until rules are applied, and it cannot be referenced as a remote for a rule variable for the same module block. If you need this value to use in a rule you are supplying, please use the `security_group_id_for_ref` output instead."
  value       = local.sg_id

  depends_on = [ibm_is_security_group_rule.security_group_rule]
}

output "security_group_id_for_ref" {
  description = "The ID of the security group which can be used as remote reference in rules. NOTE: This value will be available as soon as the security group is created, and before rules are applied, which means it can be referenced as a remote in the rules input variable itself. If you require that all rules are applied first, please use the `security_group_id` output instead."
  value       = local.sg_id
}

output "security_group_rule" {
  description = "Security group rules"
  value       = ibm_is_security_group_rule.security_group_rule
}

##############################################################################
