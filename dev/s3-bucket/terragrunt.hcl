terraform {
  source = "../../../modules//s3-buckets"
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
    s3_buckets = include.env.locals.s3_buckets
}