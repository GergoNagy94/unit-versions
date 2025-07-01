terraform {
  source = "../../../modules//acm-certificates"
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
  acms = include.env.locals.route53_zones
}

skip = include.env.locals.skip_module.acm