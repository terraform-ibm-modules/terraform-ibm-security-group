# IBM Security Group for VPC module
<!-- UPDATE BADGE: Update the link for the following badge-->
[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-security-group?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-security-group/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)


This module supports most operations on security groups for VPC. For more information, see [About security groups](https://cloud.ibm.com/docs/vpc?topic=vpc-using-security-groups) in the IBM Cloud Docs.

The module supports the following scenarios:
- Create a security group in a VPC
- Create security group rules for a new or existing security group
- Create pre-defined security group rules to cover the range of IBM Cloud internal CIDRs for ([service endpoints](https://cloud.ibm.com/docs/vpc?topic=vpc-service-endpoints-for-vpc#cloud-service-endpoints) and [IaaS endpoints](https://cloud.ibm.com/docs/vpc?topic=vpc-service-endpoints-for-vpc#infrastructure-as-a-service-iaas-endpoints))
- Attach a security group to one or more existing targets in the VPC (for example, VSI network interface, VPC load balancer, Virtual Private Endpoint gateways, VPC VPN servers)

See the following [examples](#Examples) section for code that illustrates these scenarios.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-security-group](#terraform-ibm-security-group)
* [Examples](./examples)
    * [Default example](./examples/default)
    * [Example to add security group rules to an existing security group (kube)](./examples/add-rules-to-existing-sg-kube)
    * [Example to add security group rules to an existing security group](./examples/add-rules-to-existing-sg)
    * [Example to attach resources to security group](./examples/sg-target-example)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-security-group
### Usage

```hcl
module "create_sgr_rule" {
  source                       = "terraform-ibm-modules/security-group/ibm"
  version                      = "latest" # Replace "latest" with a release version to lock into a specific release
  add_ibm_cloud_internal_rules = true
  security_group_name          = "test-sg"
  security_group_rules         = [{
    name      = "allow-all-inbound"
    direction = "inbound"
    remote    = "0.0.0.0/0"
  }]
  target_ids                   = ["r006-37e5b107-3006-480b-a340-bb1951357a73"]
}
```

### Required IAM access policies

You need the following permissions to run this module.

- IAM services
    - **VPC Infrastructure** services
        - `Editor` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.52.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_security_group.sg](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group) | resource |
| [ibm_is_security_group_rule.security_group_rule](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group_rule) | resource |
| [ibm_is_security_group_target.sg_target](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group_target) | resource |
| [ibm_is_security_group.existing_sg](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_security_group) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_ibm_cloud_internal_rules"></a> [add\_ibm\_cloud\_internal\_rules](#input\_add\_ibm\_cloud\_internal\_rules) | Add IBM cloud Internal rules to the provided security group rules | `bool` | `false` | no |
| <a name="input_existing_security_group_name"></a> [existing\_security\_group\_name](#input\_existing\_security\_group\_name) | Name of an existing security group. If set, rules will be added to the specified security group. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | An existing resource group name to use for this example, if unset a new resource group will be created | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of the security group to be created | `string` | `"test-sg"` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | A list of security group rules to be added to the default vpc security group | <pre>list(<br>    object({<br>      name      = string<br>      direction = optional(string, "inbound")<br>      remote    = string<br>      tcp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      udp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      icmp = optional(<br>        object({<br>          type = optional(number)<br>          code = optional(number)<br>        })<br>      )<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_target_ids"></a> [target\_ids](#input\_target\_ids) | (Optional) A list of target identifiers from the same VPC as the security group. It may contain one or more of the following identifiers: network interface, application load balancer, endpoint gateway, and VPN server | `list(string)` | `[]` | no |
| <a name="input_use_existing_security_group"></a> [use\_existing\_security\_group](#input\_use\_existing\_security\_group) | If set, the modules modifies the specified existing\_security\_group\_name. | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to create security group. Only required if 'existing\_security\_group\_name' is null | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group where the rules are added |
| <a name="output_security_group_rule"></a> [security\_group\_rule](#output\_security\_group\_rule) | Security group rules |
| <a name="output_security_target"></a> [security\_target](#output\_security\_target) | Resources added to the security group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
