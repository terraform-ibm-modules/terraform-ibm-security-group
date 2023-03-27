##############################################################################
# Input Variables
##############################################################################

variable "security_group_rules" {
  description = "A list of security group rules to be added to the default vpc security group"
  type = list(
    object({
      add_ibm_cloud_internal_rules = optional(bool)
      name                         = string
      direction                    = string
      remote                       = string
      tcp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      udp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      icmp = optional(
        object({
          type = optional(number)
          code = optional(number)
        })
      )
    })
  )
  default = []
}

variable "security_group_id" {
  description = "ID of the security group to which the rules are to be attached"
  type        = string
  default     = null
}
