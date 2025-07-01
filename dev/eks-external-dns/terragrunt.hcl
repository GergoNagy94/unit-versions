terraform {
  source = "git::https://github.com/lablabs/terraform-aws-eks-external-dns.git?ref=v2.0.0"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents  = file("../../../provider-config/eks-external-dns-provider/eks-external-dns-provider.tf")
}

inputs = {
  cluster_identity_oidc_issuer     = dependency.eks.outputs.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = dependency.eks.outputs.oidc_provider_arn

  helm_chart_version    = include.env.locals.external_dns_helm_chart_version
  irsa_role_name_prefix = include.env.locals.external_dns_irsa_role_name_prefix
  irsa_tags             = include.env.locals.tags
  values                = include.env.locals.external_dns_values
}

dependency "eks" {
  config_path = "${get_original_terragrunt_dir()}/../eks"

  mock_outputs = {
    cluster_name            = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
    oidc_provider_arn       = "arn:::"
  }
}

skip = include.env.locals.skip_module.eks_alb