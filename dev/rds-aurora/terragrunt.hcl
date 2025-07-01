terraform {
  source = "tfr:///cloudposse/rds-cluster/aws//.?version=1.7.0"
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
    name                              = include.env.locals.rds_aurora_name
    engine                            = include.env.locals.rds_aurora_engine
    engine_version                    = include.env.locals.rds_aurora_engine_version
    cluster_family                    = include.env.locals.rds_aurora_cluster_family
    instance_type                     = include.env.locals.rds_aurora_instance_type
    admin_user                        = include.env.locals.rds_aurora_admin_user
    admin_password                    = include.env.locals.rds_aurora_admin_password
    storage_encrypted                 = include.env.locals.rds_aurora_storage_encrypted
    apply_immediately                 = include.env.locals.rds_aurora_apply_immediately
    rds_monitoring_interval           = include.env.locals.rds_aurora_rds_monitoring_interval
    enhanced_monitoring_role_enabled  = include.env.locals.rds_aurora_enhanced_monitoring_role_enabled
    retention_period                  = include.env.locals.rds_aurora_retention_period
    subnet_group_name                 = include.env.locals.rds_aurora_subnet_group_name
    cluster_parameters                = include.env.locals.rds_aurora_parameters
    instance_parameters               = include.env.locals.rds_aurora_parameters
    deletion_protection               = include.env.locals.rds_aurora_deletion_protection
    skip_final_snapshot               = include.env.locals.rds_aurora_skip_final_snapshot
    cluster_size                      = include.env.locals.rds_aurora_cluster_size
    vpc_id                            = dependency.vpc.outputs.vpc_id
    subnets                           = dependency.vpc.outputs.private_subnets
    kms_key_arn                       = dependency.kms.outputs.key_arn
    security_groups                   = [
        dependency.vpc.outputs.default_security_group_id, 
        dependency.eks.outputs.node_security_group_id,
        dependency.bastion.outputs.security_group_id
        ]
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"

  mock_outputs = {
    azs             = ["az1", "az2", "az3"]
    vpc_id          = "vpc1"
    default_security_group_id = "sg-00000000"
    private_subnets = [
      "subnet-00000000",
      "subnet-00000001",
      "subnet-00000002",
    ]
  }
}

dependency "kms" {
  config_path = "${get_original_terragrunt_dir()}/../kms"

  mock_outputs = {
    key_arn = "arn:aws:::::"
  }
}

dependency "eks" {
  config_path = "${get_original_terragrunt_dir()}/../eks"

  mock_outputs = {
    node_security_group_id = "sg-00000000"
  }
}

dependency "bastion" {
  config_path = "${get_original_terragrunt_dir()}/../ec2-bastion"

  mock_outputs = {
    security_group_id = "sg-00000000"
  }
}

skip = include.env.locals.skip_module.rds_aurora