terraform {
  source = "tfr:///terraform-aws-modules/route53/aws//modules/zones/.?version=4.1.0"
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

  zones = {
    "${include.env.locals.domain}" = {
      comment = "${include.env.locals.domain} domain"
    }
  }
  tags  = include.env.locals.tags
}

skip = include.env.locals.skip_module.route53_zone
