terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v4.7.0"

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
  bucket          = include.env.locals.observability_logs_bucket_name
  force_destroy   = include.env.locals.observability_bucket_force_destroy
  lifecycle_rules = include.env.locals.observability_bucket_lifecycle_policy
}
  
skip = include.env.locals.skip_module.observability_logs_s3