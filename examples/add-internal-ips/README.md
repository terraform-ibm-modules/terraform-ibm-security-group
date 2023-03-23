# Add Internal IPs example

An example that appends or prepends IBM Internal IPs to the customer provided security group rules
This example uses the IBM Cloud terraform provider to:
 - Create a new resource group if one is not passed in.
 - Create a new VPC in the resource group if vpc is not provided
 - Create security group rules in the default security group in the VPC created with Internal IPs

<!-- Add your example and link to it from the module's main readme file. -->
