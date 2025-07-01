terraform {
source = "git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.48.0"
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
  name        = include.env.locals.eks_cloudwatch_policy_name
  description = include.env.locals.eks_cloudwatch_policy_description
  policy      = include.env.locals.eks_cloudwatch_policy
  tags        = include.env.locals.tags
}


skip = include.env.locals.skip_module.eks_cloudwatch_logs_policy