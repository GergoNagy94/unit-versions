terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=5.57.0"
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
  role_name                      = include.env.locals.eks_cloudwatch_logs_irsa_role_name
  oidc_providers = {
    main = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = include.env.locals.eks_cloudwatch_logs_irsa_namespace_service_accounts
    }
  }
  role_policy_arns               = {
    policy = dependency.iam_policy.outputs.arn
  }
  tags = include.env.locals.tags
}

dependency "iam_policy" {
  config_path = "${get_original_terragrunt_dir()}/../eks-cloudwatch-logs-policy"

  mock_outputs = {
    arn = "arn:aws:iam::aws:policy/ExampleAccess"
  }
}

dependency "eks" {
  config_path = "${get_original_terragrunt_dir()}/../eks"

  mock_outputs = {
    oidc_provider_arn       = "arn:::::"
  }
}

skip = include.env.locals.skip_module.irsa