<!-- BEGIN MODULE HOOK -->

<!-- Update the title to match the module name and add a description -->
# IBM Security Group module
<!-- UPDATE BADGE: Update the link for the following badge-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build status](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-security-group/actions/workflows/ci.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-module-template?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-security-group/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

With this module you can create the following infrastructure:
- Add security rules to a new or existing security group
- Optionally create a new security group
- Optionally add a list of security rules corresponding to the internal IBM flows
- Optionally attach a security group to one or several targets (network interface, VPC load balancer, virtual private endpoint gateways, VPC VPN servers)

## Usage

```hcl
module "create_sgr_rule" {
  source               = "git::https://github.com/terraform-ibm-modules/terraform-ibm-security-group"
  security_group_rules = [{
    name      = "allow-all-inbound"
    direction = "inbound"
    remote    = "0.0.0.0/0"
  }]
  target_ids            = ["r006-37e5b107-3006-480b-a340-bb1951357a73"]
  security_group_id    = "r006-16838c70-cb9b-4cb6-a605-4bfd4618e96a"
}
```

## Required IAM access policies

You need the following permissions to run this module.

- IAM services
    - **VPC Infrastructure** services
        - `Editor` platform access

## Examples

- [ Default example](examples/default)
- [ Example that creates a new security group](examples/complete)
- [ Example that adds internal IBM IPs to security group rules](examples/add-internal-ips)
<!-- END EXAMPLES HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.51.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_is_security_group.sg](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group) | resource |
| [ibm_is_security_group_rule.security_group_rule](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group_rule) | resource |
| [ibm_is_security_group_target.sg_target](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | True to create new security group. False if security group is already existing and security group rules are to be added | `bool` | `false` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | An existing resource group name to use for this example, if unset a new resource group will be created | `string` | `null` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | ID of the security group to which the rules are to be attached | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of the security group to be created | `string` | `"test-sg"` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | A list of security group rules to be added to the default vpc security group | <pre>list(<br>    object({<br>      add_ibm_cloud_internal_rules = optional(bool)<br>      name                         = string<br>      direction                    = string<br>      remote                       = string<br>      tcp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      udp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      icmp = optional(<br>        object({<br>          type = optional(number)<br>          code = optional(number)<br>        })<br>      )<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_target_ids"></a> [target\_ids](#input\_target\_ids) | (Optional) A list of target identifiers from the same VPC as the security group. It may contain one or more of the following identifiers: network interface, application load balancer, endpoint gateway, and VPN server | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to create security group. Only required if 'create\_security\_group' is true | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_rule"></a> [security\_group\_rule](#output\_security\_group\_rule) | Security group rules |
| <a name="output_security_target"></a> [security\_target](#output\_security\_target) | Security targets attached |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
