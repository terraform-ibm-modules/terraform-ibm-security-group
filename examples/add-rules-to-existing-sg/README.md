# Example to add security group rules to an existing security group

An example that demonstrates how to use the module to add security group rules to an existing security group.
This is useful in particular for security groups created by IBM Cloud stack, such as the [default VPC security group](https://cloud.ibm.com/docs/vpc?topic=vpc-updating-the-default-security-group&interface=ui), or the security groups created by the [IBM Cloud OpenShift stack](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group&interface=ui).

This example adds the following rules to the existing default VPC security group:

- IBM internal rules inbound and outbound.
- Allow inbound 192.0.2.0/24 (example CIDR block).
