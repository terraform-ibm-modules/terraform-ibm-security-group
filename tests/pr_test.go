// Tests in this file are run in the PR pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "examples/default"
const sgTargetExampleTerraformDir = "examples/sg-target-example"
const addRulesExampleTerraformDir = "examples/add-rules-to-existing-sg"

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		Prefix:        "test-sgr-default",
		ResourceGroup: resourceGroup,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunDefaultExampleWithoutIBMRules(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		Prefix:        "test-sgr-default",
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"add_ibm_cloud_internal_rules": false,
			"security_group_rules": []map[string]interface{}{
				{
					"name":      "sgr-tcp",
					"direction": "inbound",
					"remote":    "0.0.0.0/0",
					"tcp": map[string]interface{}{
						"port_min": 8080,
						"port_max": 8080,
					},
				},
			},
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunSGTargetExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  sgTargetExampleTerraformDir,
		Prefix:        "test-sgr-target",
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"region":                       "us-south", // ensuring VPC and subnet are created in same region to avoid invalid zone error
			"add_ibm_cloud_internal_rules": false,
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunAddRulesExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  addRulesExampleTerraformDir,
		Prefix:        "test-add-rules-target",
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"region": "us-south", // ensuring VPC and subnet are created in same region to avoid invalid zone error
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunSGTargetExampleNoRules(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  sgTargetExampleTerraformDir,
		Prefix:        "test-sgr-target",
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"region":               "us-south", // ensuring VPC and subnet are created in same region to avoid invalid zone error
			"security_group_rules": []map[string]interface{}{},
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		Prefix:        "test-sgr-upg",
		ResourceGroup: resourceGroup,
	})

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
