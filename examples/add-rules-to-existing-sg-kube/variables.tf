# Common variables
variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region where the cluster is located"
}

variable "cluster_id" {
  type        = string
  description = "Prefix to append to all resources created by this example"
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
