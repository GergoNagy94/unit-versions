terraform {
  source = "../../../modules//ecr-repositories"
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
  ecrs = include.env.locals.ecr_repositories
}

skip = include.env.locals.skip_module.ecr