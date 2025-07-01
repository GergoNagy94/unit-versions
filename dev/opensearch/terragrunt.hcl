terraform {
  source = "../../../modules//opensearch"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  name                                           = "codefactory-logging"
  region                                         = "eu-west-2"
  advanced_security_options_enabled              = false
  default_policy_for_fine_grained_access_control = true
  internal_user_database_enabled                 = true
  node_to_node_encryption                        = true

  master_password = "Password+1"
  master_user_name = "admin"

  tags = include.env.locals.tags
}

skip = include.env.locals.skip_module.opensearch