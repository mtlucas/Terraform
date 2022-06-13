terraform {
  required_providers {
    # Because we're currently using a built-in provider as
    # a substitute for dedicated Terraform language syntax
    # for now, test suite modules must always declare a
    # dependency on this provider. This provider is only
    # available when running tests, so you shouldn't use it
    # in non-test modules.
    test = {
      source = "terraform.io/builtin/test"
    }
    http = {
      source = "hashicorp/http"
    }
    assert = {
      source  = "bwoznicki/assert"
      version = "0.0.1"
    }
  }
}

module "main" {
  # source is always ../.. for test suite configurations,
  # because they are placed two subdirectories deep under
  # the main module directory.
  source = "../.."

  # This test suite is aiming to test the "defaults" for
  # this module, so it doesn't set any input variables
  # and just lets their default values be selected instead.
}

# As with all Terraform modules, we can use local values
# to do any necessary post-processing of the results from
# the module in preparation for writing test assertions.
#locals {
#  win_build_agent_vm_template_upgrade_map = { "TCBUILD01" = false }
#}

# The special test_assertions resource type, which belongs
# to the test provider we required above, is a temporary
# syntax for writing out explicit test assertions.
resource "test_assertions" "vsphere_virtual_machine" {
  # "component" serves as a unique identifier for this
  # particular set of assertions in the test results.
  component = "vsphere_virtual_machine"

  # equal and check blocks serve as the test assertions.
  # the labels on these blocks are unique identifiers for
  # the assertions, to allow more easily tracking changes
  # in success between runs.

  equal "vm_name" {
    description = "Default vm_name is TCBUILD01"
    got         = module.main.vm_name
    want        = "TCBUILD01"
  }
}

# We can also use data resources to respond to the
# behavior of the real remote system, rather than
# just to values within the Terraform configuration.
#data "http" "api_response" {
#  depends_on = [
    # make sure the syntax assertions run first, so
    # we'll be sure to see if it was URL syntax errors
    # that let to this data resource also failing.
#    test_assertions.api_url,
#  ]
#  url = module.main.api_url
#}
