
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
