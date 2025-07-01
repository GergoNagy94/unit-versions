terraform {
  source = "../../../modules//route53-zones"
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
  zones = include.env.locals.route53_zones
}

skip = include.env.locals.skip_module.route53_records