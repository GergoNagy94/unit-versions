terraform {
  source = "git@github.com:notespacejp/terraform-aws-s3-alb-log.git?ref=1.0.2"
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
  bucket_name = "${include.env.locals.env}-${include.env.locals.project}-alb-log-bucket"
}

skip = include.env.locals.skip_module.eks_alb_log