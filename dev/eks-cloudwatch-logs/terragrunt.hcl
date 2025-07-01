terraform {
  source = "git@github.com:cloudposse/terraform-aws-helm-release.git?ref=0.10.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents  = file("../../../provider-config/eks-helm-provider/eks-helm-provider.tf")
}

inputs = {
  repository                  = include.env.locals.eks_cloudwatch_helm_chart_repository
  chart                       = include.env.locals.eks_cloudwatch_helm_chart_name
  chart_version               = include.env.locals.eks_cloudwatch_helm_chart_version
  eks_cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url

  kubernetes_namespace        = include.env.locals.eks_cloudwatch_kubernetes_namespace
  atomic                      = include.env.locals.eks_cloudwatch_atomic
  cleanup_on_fail             = include.env.locals.eks_cloudwatch_cleanup_on_fail


  values                      = include.env.locals.eks_cloudwatch_values

  tags = {
    cluster_name              = "${include.env.locals.env}-${include.env.locals.project}"
  }
}

dependency "eks" {
  config_path = "${get_original_terragrunt_dir()}/../eks"

  mock_outputs = {
    cluster_name            = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
    oidc_provider_arn       = "arn:::::"
  }
}

dependency "eks-cloudwatch-irsa" {
  config_path = "${get_original_terragrunt_dir()}/../eks-cloudwatch-logs-irsa"

  skip_outputs = true
}

skip = include.env.locals.skip_module.observability_grafana