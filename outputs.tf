##############################################################################
# Outputs
##############################################################################

output "security_target" {
  description = "Resources added to the security group"
  value       = ibm_is_security_group_target.sg_target
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = local.sg_id
}
