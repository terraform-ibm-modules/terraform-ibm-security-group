
# Common variables
variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
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
  default = [{
    name      = "allow-all-inbound"
    direction = "inbound"
    remote    = "0.0.0.0/0"
  }]
}

# VPC variables
variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
  default     = null
}

# Subnet variables
variable "zone" {
  type        = string
  description = "The subnet zone name"
}

variable "total_ipv4_address_count" {
  type        = number
  description = "(Optional) The IPv4 range of the subnet. Either ipv4_cidr_block or total_ipv4_address_count input must be provided in the resource"
  default     = 256
}

variable "access_tags" {
  description = "A list of access management tags to attach to the security group. For more information, see [working with tags](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)"
  type        = list(string)
  default     = []
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "add_ibm_cloud_internal_rules" {
  description = "Add IBM cloud Internal rules to the provided security group rules"
  type        = bool
  default     = false
}
