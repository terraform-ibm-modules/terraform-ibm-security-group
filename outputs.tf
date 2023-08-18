##############################################################################
# Security Group Outputs
##############################################################################

output "id" {
  description = "ID of the Security Group"
  value       = ibm_is_security_group.security_group.id
  depends_on = [
    ibm_is_security_group_rule.rule
  ]
}

##############################################################################