# Default example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=security-group-default-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-security-group/tree/main/examples/default"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


A default example that uses the module's default variable values.
This example uses the IBM Cloud Terraform provider to create this infrastructure:

 - A resource group, if one is not passed in.
 - A VPC, if one is not passed in.
 - A security group, if one is not passed in
 - Security group rules with CIDR blocks in a security group
 - Security group rules with an existing security group in a security group

<!-- Add your example and link to it from the module's main readme file. -->

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
