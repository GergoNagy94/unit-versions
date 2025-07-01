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
  role_name                      = include.env.locals.irsa_role_name
  attach_ebs_csi_policy          = include.env.locals.irsa_attach_ebs_csi_policy
  ebs_csi_kms_cmk_ids            = include.env.locals.irsa_ebs_csi_kms_cmk_ids
  external_secrets_kms_key_arns  = include.env.locals.irsa_external_secrets_kms_key_arns
  oidc_providers = {
    main = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = include.env.locals.irsa_namespace_service_accounts
    }
  }
  tags = include.env.locals.tags
}

dependency "eks" {
  config_path = "${get_original_terragrunt_dir()}/../eks"

  mock_outputs = {
    oidc_provider_arn       = "arn:::"
  }
}

skip = include.env.locals.skip_module.irsa