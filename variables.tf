##############################################################################
# Variables
##############################################################################

variable "vpc_id" {
  description = "VPC ID where the security group will be provisioned"
  type        = string
}

variable "name" {
  description = "Security Group name. Name prefix that will be prepended to named resources"
  type        = string
  validation {
    error_message = "Security Group Name must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Name must end with a lowercase letter or number."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])", var.name))
  }
}

variable "resource_group_id" {
  description = "ID for the resource group where resources will be created"
  type        = string
}

variable "tags" {
  description = "List of tags"
  type        = list(string)
}

variable "prefix" {
  description = "Name prefix that will be prepended to named resources"
  type        = string
  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])", var.prefix)) && length(var.prefix) <= 24
  }
}

##############################################################################

##############################################################################
# Rules Variable
##############################################################################

variable "rules" {
  description = "A list of security group rules to be added to a security group."
  type = list(
    object({
      name      = string
      direction = string
      remote    = string
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

  validation {
    error_message = "Security group rules can only have one of `icmp`, `udp`, or `tcp`."
    condition = (var.rules == null || length(var.rules) == 0) ? true : length(distinct(
      # Get flat list of results
      flatten([
        # Check through rules
        for rule in var.rules :
        # Return true if there is more than one of `icmp`, `udp`, or `tcp`
        true if length(
          [
            for type in ["tcp", "udp", "icmp"] :
            true if rule[type] != null
          ]
        ) > 1
      ])
    )) == 0 # Checks for length. If all fields all correct, array will be empty
  }

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = (var.rules == null || length(var.rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.rules :
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  # validation {
  #   error_message = "Security group rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
  #   condition = (var.rules == null || length(var.rules) == 0) ? true : length(distinct(
  #     flatten([
  #       # Check through rules
  #       for rule in var.rules :
  #       # Return false if direction is not valid
  #       false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", rule.name))
  #     ])
  #   )) == 0
  # }
}

##############################################################################
