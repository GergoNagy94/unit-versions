terraform {
  source = "tfr:///cloudposse/elasticache-redis/aws//.?version=1.2.0"
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
    name                                 = include.env.locals.redis_name
    vpc_id                               = dependency.vpc.outputs.vpc_id
    availability_zones                   = include.env.locals.availability_zone
    subnets                              = dependency.vpc.outputs.private_subnets
    cluster_size                         = include.env.locals.redis_cluster_size
    instance_type                        = include.env.locals.redis_instance_type
    apply_immediately                    = include.env.locals.redis_apply_immediately
    automatic_failover_enabled           = include.env.locals.redis_automatic_failover_enabled
    engine_version                       = include.env.locals.redis_engine_version
    family                               = include.env.locals.redis_family
    at_rest_encryption_enabled           = include.env.locals.redis_at_rest_encryption_enabled
    transit_encryption_enabled           = include.env.locals.redis_transit_encryption_enabled
    kms_key_id                           = dependency.kms.outputs.key_arn
    maintenance_window                   = include.env.locals.redis_maintenance_window
    
    # security group inputs
    security_group_create_before_destroy = include.env.locals.redis_security_group_create_before_destroy
    allowed_security_group_ids           = [
        dependency.vpc.outputs.default_security_group_id, 
        dependency.eks.outputs.node_security_group_id,
        dependency.bastion.outputs.security_group_id,
      ]

    security_group_name                  = [include.env.locals.redis_security_group_name]
    allow_all_egress                     = include.env.locals.redis_allow_all_egress

    tags                                 = include.env.locals.tags
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

skip = include.env.locals.skip_module.redis