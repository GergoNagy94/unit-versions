terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=v3.1.1"
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
  aliases                    = ["${include.env.locals.env}-${include.env.locals.project}"]
  description                = "KMS key for RDS MySQL, Redis and EKS cluster"
  customer_master_key_spec   = include.env.locals.kms_customer_master_key_spec
  key_usage                  = include.env.locals.kms_key_usage
  key_administrators         = include.env.locals.kms_key_administrators
  tags                       = include.env.locals.tags
}

skip = include.env.locals.skip_module.kms