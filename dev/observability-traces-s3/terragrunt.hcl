terraform {
  source = "git.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v6.0.1"

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
  bucket          = include.env.locals.observability_traces_bucket_name
  force_destroy   = include.env.locals.observability_bucket_force_destroy
  lifecycle_rules = include.env.locals.observability_bucket_lifecycle_policy
}
  
skip = include.env.locals.skip_module.observability_traces_s3