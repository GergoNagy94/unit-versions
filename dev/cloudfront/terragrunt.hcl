terraform {
  source = "../../../modules//cloudfront"
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
  name                = include.env.locals.cloudfront_distribution_name
  origin_bucket_name  = include.env.locals.cloudfront_distribution_name
  aliases             = include.env.locals.cloudfront_distribution_aliases
  parent_zone_name    = include.env.locals.cloudfront_distribution_parent_zone_name
  acm_certificate_arn = include.env.locals.cloudfront_distribution_acm_certificate_arn
  allowed_methods     = include.env.locals.cloudfront_distribution_allowed_methods
  cached_methods      = include.env.locals.cloudfront_distribution_cached_methods
  tags                = include.env.locals.tags
}

skip = include.env.locals.skip_module.cloudfront