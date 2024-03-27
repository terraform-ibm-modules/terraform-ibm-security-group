# Example to add security group rules to an existing security group (kube)

An example that demonstrates how to use the module to add rules to the security groups created by the IBM Cloud OpenShift stack.

For context on the security groups created by the IBM Cloud Openshift stack, refer to the [IBM Cloud Docs](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group&interface=ui).

This example is written for OpenShift version up to 4.13.

This illustrative example adds the following rules:

1. To the security group attached to the cluster worker nodes (named kube-<clusterId>):
   - Allow inbound 192.0.2.0/24 (example CIDR block).
2. To the security group attached to the LB and VPCs (named kube-<vpcid>):
   - Allow inbound 192.0.2.0/24 (example CIDR block).
