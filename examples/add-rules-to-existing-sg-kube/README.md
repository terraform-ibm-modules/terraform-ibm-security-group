# Example to add security group rules to an existing security group (kube)

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=security-group-add-rules-to-existing-sg-kube-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-security-group/tree/main/examples/add-rules-to-existing-sg-kube"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An example that demonstrates how to use the module to add rules to the security groups created by the IBM Cloud OpenShift stack.

For context on the security groups created by the IBM Cloud Openshift stack, refer to the [IBM Cloud Docs](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group&interface=ui).

This example is written for OpenShift version up to 4.13.

This illustrative example adds the following rules:

1. To the security group attached to the cluster worker nodes (named kube-<clusterId>):
   - Allow inbound 192.0.2.0/24 (example CIDR block).
2. To the security group attached to the LB and VPCs (named kube-<vpcid>):
   - Allow inbound 192.0.2.0/24 (example CIDR block).

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
