terraform {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git?ref=0.11.0"
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
  contents  = file("../../../provider-config/eks-addons/eks-addons.tf")
}

inputs = {
  cluster_identity_oidc_issuer     = dependency.eks.outputs.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = dependency.eks.outputs.oidc_provider_arn
  cluster_name                     = dependency.eks.outputs.cluster_name

  helm_chart_name                  = include.env.locals.alb_helm_chart_name
  helm_chart_release_name          = include.env.locals.alb_helm_chart_release_name
  helm_chart_repo                  = include.env.locals.alb_helm_chart_repository
  helm_chart_version               = include.env.locals.alb_helm_chart_version
  namespace                        = include.env.locals.alb_kubernetes_namespace
  service_account_name             = include.env.locals.alb_service_account_name
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