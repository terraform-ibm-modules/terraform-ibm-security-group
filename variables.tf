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

variable "security_group_name" {
  description = "Name of the security group to be created"
  type        = string
  default     = "test-sg"
}

variable "vpc_id" {
  description = "ID of the VPC to create security group. Only required if 'create_security_group' is true"
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

variable "create_security_group" {
  description = "True to create new security group. False if security group is already existing and security group rules are to be added"
  type        = bool
  default     = false
}
