terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=v5.57.0"
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
  role_name = include.env.locals.fluentbit_irsa_role_name
  oidc_providers = {
    main = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = include.env.locals.fluentbit_irsa_namespace_service_accounts
    }
  }
  role_policy_arns = {
    policy = dependency.fluentbit-policy.outputs.arn
  }
  tags = include.env.locals.tags
}

dependency "eks" {
  config_path = "${get_original_terragrunt_dir()}/../eks"

  mock_outputs = {
    oidc_provider_arn = "arn:::"
  }
}

dependency "fluentbit-policy" {
  config_path = "${get_original_terragrunt_dir()}/../fluentbit-policy"

  mock_outputs = {
    arn = "arn:aws:iam::000000000000:policy/ExamplePolicy"
  }
}

skip = include.env.locals.skip_module.fluentbit_irsa