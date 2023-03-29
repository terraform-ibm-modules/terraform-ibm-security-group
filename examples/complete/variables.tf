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

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "classic_access" {
  description = "OPTIONAL - Classic Access to the VPC"
  type        = bool
  default     = false
}

variable "use_manual_address_prefixes" {
  description = "OPTIONAL - Use manual address prefixes for VPC"
  type        = bool
  default     = false
}

variable "default_network_acl_name" {
  description = "OPTIONAL - Name of the Default ACL. If null, a name will be automatically generated"
  type        = string
  default     = null
}

variable "default_security_group_name" {
  description = "OPTIONAL - Name of the Default Security Group. If null, a name will be automatically generated"
  type        = string
  default     = null
}

variable "default_routing_table_name" {
  description = "OPTIONAL - Name of the Default Routing Table. If null, a name will be automatically generated"
  type        = string
  default     = null
}

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
    add_ibm_cloud_internal_rules = true
    name                         = "default-complete-sgr-tcp"
    direction                    = "inbound"
    remote                       = "0.0.0.0/0"
    tcp = {
      port_min = 8080
      port_max = 8080
    }
    }, {
    add_ibm_cloud_internal_rules = true
    name                         = "default-complete-sgr-udp"
    direction                    = "inbound"
    remote                       = "0.0.0.0/0"
    udp = {
      port_min = 805
      port_max = 807
    }
    },
    {
      add_ibm_cloud_internal_rules = true
      name                         = "default-complete-sgr-icmp"
      direction                    = "inbound"
      remote                       = "0.0.0.0/0"
      icmp = {
        code = 20
        type = 30
      }

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

variable "security_group_id" {
  description = "ID of the security group to which the rules are to be attached"
  type        = string
  default     = null
}
