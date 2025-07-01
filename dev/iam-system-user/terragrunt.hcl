terraform {
  source  = "../../../modules//iam-system-users"
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
  iam_system_users = include.env.locals.iam_system_users
}



skip = include.env.locals.skip_module.iam_system_user