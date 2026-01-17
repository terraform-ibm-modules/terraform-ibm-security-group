# Example to add security group rules to an existing security group

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=security-group-add-rules-to-existing-sg-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-security-group/tree/main/examples/add-rules-to-existing-sg"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An example that demonstrates how to use the module to add security group rules to an existing security group.
This is useful in particular for security groups created by IBM Cloud stack, such as the [default VPC security group](https://cloud.ibm.com/docs/vpc?topic=vpc-updating-the-default-security-group&interface=ui), or the security groups created by the [IBM Cloud OpenShift stack](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group&interface=ui).

This example adds the following rules to the existing default VPC security group:

- IBM internal rules inbound and outbound.
- Allow inbound 192.0.2.0/24 (example CIDR block).

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
