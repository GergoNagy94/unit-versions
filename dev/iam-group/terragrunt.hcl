terraform {
  source  = "../../../modules//iam-groups"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  iam_groups = include.env.locals.iam_groups
}


dependency "iam_user" {
  config_path = "${get_original_terragrunt_dir()}/../iam-user"
  skip_outputs = true
}

skip = include.env.locals.skip_module.iam_group