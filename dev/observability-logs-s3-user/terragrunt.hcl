terraform {
  source = "git@github.com:cloudposse/terraform-aws-iam-s3-user.git?ref=1.2.1"
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
    name                          = include.env.locals.observability_logs_s3_user_name
    create_iam_access_key         = include.env.locals.observability_s3_user_create_iam_access_key
    ssm_enabled                   = include.env.locals.observability_s3_user_ssm_enabled
    force_destroy                 = include.env.locals.observability_s3_user_force_destroy
    s3_actions                    = include.env.locals.observability_s3_user_actions
    s3_resources                  = include.env.locals.observability_logs_s3_user_resources
    tags                          = include.env.locals.tags 
}

skip = include.env.locals.skip_module.observability_logs_s3_user