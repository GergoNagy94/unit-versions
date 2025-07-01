terraform {
  source = "git.com:cloudposse/terraform-aws-mq-broker.git?ref=3.1.0"
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
    name                       = include.env.locals.rabbit_name
    rabbit_mq_admin_user       = include.env.locals.rabbit_mq_admin_user
    rabbit_mq_admin_password   = include.env.locals.rabbit_mq_admin_password
    apply_immediately          = include.env.locals.rabbit_apply_immediately
    auto_minor_version_upgrade = include.env.locals.rabbit_auto_minor_version_upgrade
    deployment_mode            = include.env.locals.rabbit_deployment_mode
    engine_type                = include.env.locals.rabbit_engine_type
    engine_version             = include.env.locals.rabbit_engine_version
    host_instance_type         = include.env.locals.rabbit_host_instance_type
    publicly_accessible        = include.env.locals.rabbit_publicly_accessible
    general_log_enabled        = include.env.locals.rabbit_general_log_enabled
    audit_log_enabled          = include.env.locals.rabbit_audit_log_enabled
    encryption_enabled         = include.env.locals.rabbit_encryption_enabled
    vpc_id                     = dependency.vpc.outputs.vpc_id
    subnet_ids                 = slice(dependency.vpc.outputs.private_subnets, 0, 2)
    maintenance_day_of_week    = include.env.locals.rabbit_maintenance_day_of_week
    maintenance_time_of_day    = include.env.locals.rabbit_maintenance_time_of_day
    maintenance_time_zone      = include.env.locals.rabbit_maintenance_time_zone

    kms_ssm_key_arn            = dependency.kms.outputs.key_arn
    kms_mq_key_arn             = dependency.kms.outputs.key_arn
    use_aws_owned_key          = include.env.locals.rabbit_use_aws_owned_key

    # security group inputs
    security_group_create_before_destroy = include.env.locals.rabbit_security_group_create_before_destroy
    allowed_security_group_ids           = [
        dependency.vpc.outputs.default_security_group_id, 
        dependency.eks.outputs.node_security_group_id,
        dependency.bastion.outputs.security_group_id,
      ]
    security_group_name                  = [include.env.locals.rabbit_security_group_name]
    additional_security_group_rules      = include.env.locals.rabbit_additional_security_group_rules
    allow_all_egress                     = include.env.locals.rabbit_allow_all_egress
    allowed_ingress_ports                = include.env.locals.rabbit_allowed_ingress_ports

    tags                       = include.env.locals.tags
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000"
    private_subnets = [
      "subnet-00000000",
      "subnet-00000001",
      "subnet-00000002",
    ]
    default_security_group_id = "sg-00000000"
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

skip = include.env.locals.skip_module.rabbitmq