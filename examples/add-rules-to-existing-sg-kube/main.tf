##############################################################################
# Find VPC ID based on the inputted cluster_id
##############################################################################

locals {
  vpc_id = data.ibm_container_vpc_worker_pool.worker_pool.vpc_id
}

data "ibm_container_vpc_cluster" "cluster" {
  name = var.cluster_id
}

# No vpc_id output on ibm_container_vpc_cluster so using the ibm_container_vpc_worker_pool data (which does have a vpc_id)
data "ibm_container_vpc_worker_pool" "worker_pool" {
  cluster          = var.cluster_id
  worker_pool_name = data.ibm_container_vpc_cluster.cluster.worker_pools[0].name
}

##############################################################################
# Build name of the SGs
# See https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group
##############################################################################

locals {
  name_of_worker_nodes_sg = "kube-${var.cluster_id}"
  name_of_lb_vpe_sg       = "kube-${local.vpc_id}"
}

##############################################################################
# Add rules to existing worker node security group
##############################################################################

module "add_rules_to_workernodes_sg" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = false # No need as handled by OpenShift stack
  use_existing_security_group  = true
  existing_security_group_name = local.name_of_worker_nodes_sg
  security_group_rules = [{
    direction  = "inbound"
    remote     = "192.0.2.0/24"
    local      = "0.0.0.0/0"
    ip_version = "ipv4"
  }]
  access_tags = var.access_tags
  tags        = var.resource_tags
}

##############################################################################
# Add rules to existing lb/vpe security group
##############################################################################

module "add_rules_to_lbvpc_sg" {
  source                       = "../.."
  add_ibm_cloud_internal_rules = false # No need as handled by OpenShift stack
  use_existing_security_group  = true
  existing_security_group_name = local.name_of_lb_vpe_sg
  security_group_rules = [{
    direction  = "inbound"
    remote     = "192.0.2.0/24"
    local      = "0.0.0.0/0"
    ip_version = "ipv4"
    tcp = {
      port_min = 443
      port_max = 443
    }
  }]
  access_tags = var.access_tags
  tags        = var.resource_tags
}
