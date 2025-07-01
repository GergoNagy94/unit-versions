terraform {
  source = "git.com:terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v4.1.0"
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
