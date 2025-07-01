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
  repository                  = include.env.locals.grafana_helm_chart_repository
  chart                       = include.env.locals.grafana_helm_chart_name
  chart_version               = include.env.locals.grafana_helm_chart_version
  eks_cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url

  create_namespace     = include.env.locals.observability_create_namespace
  kubernetes_namespace = include.env.locals.grafana_namespace
  atomic               = include.env.locals.observability_atomic
  cleanup_on_fail      = include.env.locals.observability_cleanup_on_fail
  force_update         = include.env.locals.observability_force_update
  wait                 = include.env.locals.observability_wait


  values = [
    templatefile("grafana.tftpl", {
      custom_dashboards = fileset("${get_original_terragrunt_dir()}/dashboards/", "*.json"),
      module_path       = get_original_terragrunt_dir()
    })

  ]

  tags = {
    cluster_name = "${include.env.locals.env}-${include.env.locals.project}"
  }
}

dependency "eks" {
  config_path = "${get_original_terragrunt_dir()}/../eks"

  mock_outputs = {
    cluster_name            = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.eu-west-3.amazonaws.com/id/0000000000000000"
    oidc_provider_arn       = "arn:::"
  }
}

skip = include.env.locals.skip_module.observability_grafana