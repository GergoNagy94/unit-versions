terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.57.0"
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
    name = "fluentbit-policy"
    policy = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "es:ESHttp*"
            ],
            "Resource": "arn:aws:es:eu-west-2:500286922458:domain/codefactory-logging",
            "Effect": "Allow"
        }
    ]
}
    description = "IAM policy for fluentbit"
    tags        = include.env.locals.tags
}

skip = include.env.locals.skip_module.fluentbit_policy