// Tests in this file are run in the PR pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "examples/default"
const sgTargetExampleTerraformDir = "examples/sg-target-example"
const addRulesExampleTerraformDir = "examples/add-rules-to-existing-sg"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	// Read the YAML file contents
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, dir string, prefix string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"access_tags": permanentResources["accessTags"],
		},
	})

	return options
}

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, defaultExampleTerraformDir, "test-sgr-default")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunDefaultExampleWithoutIBMRules(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  defaultExampleTerraformDir,
		Prefix:        "test-sgr-no-rules",
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"access_tags":                  permanentResources["accessTags"],
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
			"access_tags":                  permanentResources["accessTags"],
			"region":                       "us-south", // ensuring VPC and subnet are created in same region to avoid invalid zone error
			"add_ibm_cloud_internal_rules": false,
			"zone":                         "us-south-1",
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
			"access_tags": permanentResources["accessTags"],
			"region":      "us-south", // ensuring VPC and subnet are created in same region to avoid invalid zone error
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
		Prefix:        "test-sgr-target-no-rules",
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"region":               "us-south", // ensuring VPC and subnet are created in same region to avoid invalid zone error
			"security_group_rules": []map[string]interface{}{},
			"zone":                 "us-south-1",
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, defaultExampleTerraformDir, "test-sgr-upg")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
