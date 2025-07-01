terraform {
  source  = "../../../modules//iam-users"
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
  iam_users = include.env.locals.iam_users
}



skip = include.env.locals.skip_module.iam_user