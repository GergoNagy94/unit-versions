terraform {
  source = "tfr:///cloudposse/ses/aws//.?version=0.25.1"
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
    domain            = include.env.locals.domain
    zone_id           = include.env.locals.route53_zones.confighu.zone_id
    verify_domain     = include.env.locals.ses_verify_domain
    ses_user_enabled  = include.env.locals.ses_user_enabled
    ses_group_enabled = include.env.locals.ses_group_enabled
    tags              = include.env.locals.tags
}

skip = include.env.locals.skip_module.ses