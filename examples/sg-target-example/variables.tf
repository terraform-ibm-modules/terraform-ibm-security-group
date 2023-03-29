
# Common variables
variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "test-sgr"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

# Security group rule variables
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
  default = [{
    add_ibm_cloud_internal_rules = false
    name                         = "allow-all-inbound"
    direction                    = "inbound"
    remote                       = "0.0.0.0/0"
  }]

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.security_group_rules :
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  validation {
    error_message = "Security group rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
    condition = (var.security_group_rules == null || length(var.security_group_rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.security_group_rules :
        # Return false if direction is not valid
        false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", rule.name))
      ])
    )) == 0
  }
}

variable "create_security_group" {
  description = "True to create new security group. False if security group is already existing and security group rules are to be added"
  type        = bool
  default     = true
}

# VPC variables
variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
  default     = null
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC to be created"
  default     = "vpc"
}

# Subnet variables
variable "zone" {
  type        = string
  description = "The subnet zone name"
  default     = "us-south-1"
}

variable "total_ipv4_address_count" {
  type        = number
  description = "(Optional) The IPv4 range of the subnet. Either ipv4_cidr_block or total_ipv4_address_count input must be provided in the resource"
  default     = 256
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}
