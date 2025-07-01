terraform {
  source = "tfr:///cloudposse/helm-release/aws//.?version=0.10.1"
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
  repository                  = include.env.locals.prometheus_helm_chart_repository
  chart                       = include.env.locals.prometheus_helm_chart_name
  chart_version               = include.env.locals.prometheus_helm_chart_version
  eks_cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url
  create_namespace            = include.env.locals.observability_create_namespace
  kubernetes_namespace        = include.env.locals.observability_namespace
  atomic                      = include.env.locals.observability_atomic
  cleanup_on_fail             = include.env.locals.observability_cleanup_on_fail
  force_update                = include.env.locals.observability_force_update
  wait                        = include.env.locals.observability_wait

  tags = {
    cluster_name              = "${include.env.locals.env}-${include.env.locals.project}"
  }

  values = [
    templatefile("prometheus.yml", {
      SLACK_API_URL = include.env.locals.slack_api_url,
      SLACK_CHANNEL = include.env.locals.slack_channel,
    }),
  ]

  set_sensitive = [
   {
    name  = "thanos.objstoreConfig"
    value = templatefile("s3.yml", {
        bucketName      = dependency.metrics_bucket.outputs.s3_bucket_id,
        region          = include.env.locals.region
        accessKeyId     = dependency.metrics_bucket_user.outputs.access_key_id
        secretAccessKey = dependency.metrics_bucket_user.outputs.secret_access_key
    })
    type = "auto"
    }
  ]
}

dependency "metrics_bucket" {
  config_path  = "${get_original_terragrunt_dir()}/../observability-metrics-s3"
  mock_outputs = {
    s3_bucket_id     = "metrics-bucket"
  }
}

dependency "metrics_bucket_user" {
  config_path = "${get_original_terragrunt_dir()}/../observability-metrics-s3-user"

  mock_outputs = {
    access_key_id           = "AAAA"
    secret_access_key       = "0000"
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


skip = include.env.locals.skip_module.observability_prometheus