terraform {
  source = "git.com:cloudposse/terraform-aws-sns-topic.git?ref=0.21.0"
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
    name        = "globalvet-topic"

    subscribers = {}
    sqs_dlq_enabled = false
    tags            = include.env.locals.tags
}

skip = include.env.locals.skip_module.sns