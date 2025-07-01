terraform {
  source = "git.com:terraform-aws-modules/terraform-aws-rds-aurora.git?ref=v9.15.0"
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

    // name                                  = include.env.locals.aurora_mysql_name
    // engine                                = include.env.locals.aurora_mysql_engine
    // engine_version                        = include.env.locals.aurora_mysql_engine_version
    // instance_class                        = include.env.locals.aurora_mysql_instance_class
    // storage_encrypted                     = include.env.locals.aurora_mysql_storage_encrypted
    // apply_immediately                     = include.env.locals.aurora_mysql_apply_immediately
    // backup_retention_period               = include.env.locals.aurora_mysql_backup_retention_period
    // create_db_subnet_group                = include.env.locals.aurora_mysql_create_db_subnet_group
    // db_subnet_group_name                  = include.env.locals.aurora_mysql_db_subnet_group_name

    # Cluster parameter group
    // create_db_cluster_parameter_group     = include.env.locals.aurora_mysql_create_db_cluster_parameter_group
    // db_cluster_parameter_group_name       = include.env.locals.aurora_mysql_db_cluster_parameter_group_name
    // db_cluster_parameter_group_family     = include.env.locals.aurora_mysql_db_parameter_group_family
    // db_cluster_parameter_group_parameters = include.env.locals.aurora_mysql_db_parameter_group_parameters

    # DB parameter group
    // create_db_parameter_group             = include.env.locals.aurora_mysql_create_db_parameter_group
    // db_parameter_group_name               = include.env.locals.aurora_mysql_db_parameter_group_name
    // db_parameter_group_family             = include.env.locals.aurora_mysql_db_parameter_group_family
    // db_parameter_group_parameters         = include.env.locals.aurora_mysql_db_parameter_group_parameters

    // iam_role_managed_policy_arns          = include.env.locals.aurora_mysql_iam_role_managed_policy_arns
    // master_username                       = include.env.locals.aurora_mysql_master_username
    // master_password                       = include.env.locals.aurora_mysql_master_password
    // deletion_protection                   = include.env.locals.aurora_mysql_deletion_protection
    // final_snapshot_identifier             = include.env.locals.aurora_mysql_final_snapshot_identifier
    // monitoring_interval                   = include.env.locals.aurora_mysql_monitoring_interval
    // instances                             = include.env.locals.aurora_mysql_instances
    // availability_zones                    = dependency.vpc.outputs.azs
    // vpc_id                                = dependency.vpc.outputs.vpc_id
    // subnets                               = dependency.vpc.outputs.private_subnets
    // kms_key_id                            = dependency.kms.outputs.key_arn
    // master_user_secret_kms_key_id         = dependency.kms.outputs.key_arn
    // vpc_security_group_ids                = [dependency.security_group.outputs.security_group_id]
    // tags                                  = include.env.locals.tags
  }

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"

  mock_outputs = {
    azs             = ["az1", "az2", "az3"]
    vpc_id          = "vpc1"
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

skip = include.env.locals.skip_module.rds_aurora_experimental