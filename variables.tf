##############################################################################
# Security Group Variables
##############################################################################

variable "security_group_name" {
  description = "Name of the security group to be created"
  type        = string
  default     = "test-sg"
}

variable "use_existing_security_group" {
  description = "If set, the modules modifies the specified existing_security_group_name."
  type        = bool
  default     = false
}

variable "existing_security_group_name" {
  description = "Name of an existing security group. Mutually exclusive with `existing_security_group_id`. If set, rules will be added to the specified security group."
  type        = string
  default     = null
}

variable "use_existing_security_group_id" {
  description = "If set, the modules modifies the specified existing_security_group_id."
  type        = bool
  default     = false
}

variable "existing_security_group_id" {
  description = "Id of an existing security group. Mutually exclusive with `existing_security_group_name`. If set, rules will be added to the specified security group."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC to create security group. Only required if 'existing_security_group_name' is null"
  type        = string
  default     = null
}

variable "resource_group" {
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  type        = string
  default     = null
}

variable "target_ids" {
  description = "(Optional) A list of target identifiers from the same VPC as the security group. It may contain one or more of the following identifiers: network interface, application load balancer, endpoint gateway, and VPN server"
  type        = list(string)
  default     = []
}

# variable "add_ibm_cloud_internal_rules" {
#   description = "Add IBM cloud Internal rules to the provided security group rules"
#   type        = bool
#   default     = false
# }

variable "access_tags" {
  description = "A list of access management tags to attach to the security group. For more information, see [working with tags](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "List of resource tags to apply to security group created by this module."
  type        = list(string)
  default     = []
}

##############################################################################

##############################################################################
# Rule Variables
##############################################################################

# variable "security_group_rules" {
#   description = "A list of security group rules to be added to the default vpc security group"
#   type = list(
#     object({
#       name      = string
#       direction = optional(string, "inbound")
#       remote    = string
#       tcp = optional(
#         object({
#           port_max = optional(number)
#           port_min = optional(number)
#         })
#       )
#       udp = optional(
#         object({
#           port_max = optional(number)
#           port_min = optional(number)
#         })
#       )
#       icmp = optional(
#         object({
#           type = optional(number)
#           code = optional(number)
#         })
#       )
#     })
#   )
#   default = []

#   validation {
#     error_message = "Security group rule direction can only be `inbound` or `outbound`."
#     condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
#       flatten([
#         # Check through rules
#         for rule in var.security_group_rules :
#         # Return false if direction is not valid
#         false if !contains(["inbound", "outbound"], rule.direction)
#       ])
#     )) == 0
#   }

#   validation {
#     error_message = "Security group rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9_]*[a-z0-9])$."
#     condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
#       flatten([
#         # Check through rules
#         for rule in var.security_group_rules :
#         # Return false if direction is not valid
#         false if !can(regex("^([a-z]|[a-z][-a-z0-9_]*[a-z0-9])$", rule.name))
#       ])
#     )) == 0
#   }

#   validation {
#     error_message = "Security group rules can only have one of `icmp`, `udp`, or `tcp`."
#     condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
#       # Get flat list of results
#       flatten([
#         # Check through rules
#         for rule in var.security_group_rules :
#         # Return true if there is more than one of `icmp`, `udp`, or `tcp`
#         true if length(
#           [
#             for type in ["tcp", "udp", "icmp"] :
#             true if rule[type] != null
#           ]
#         ) > 1
#       ])
#     )) == 0 # Checks for length. If all fields all correct, array will be empty
#   }
# }

##############################################################################
