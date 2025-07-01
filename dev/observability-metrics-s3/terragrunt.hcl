terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws////.?version=4.1.2"

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
  bucket         = include.env.locals.observability_metrics_bucket_name
  force_destroy  = include.env.locals.observability_bucket_force_destroy
  lifecycle_rule = include.env.locals.observability_bucket_lifecycle_policy
}
  
skip = include.env.locals.skip_module.observability_metrics_s3