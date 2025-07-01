terraform {
  source = "tfr:///terraform-aws-modules/rds/aws//.?version=6.4.0"
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
  identifier                            = include.env.locals.mysql_identifier
  engine                                = include.env.locals.mysql_engine
  engine_version                        = include.env.locals.mysql_engine_version
  instance_class                        = include.env.locals.mysql_instance_class
  allocated_storage                     = include.env.locals.mysql_allocated_storage
  db_name                               = include.env.locals.mysql_db_name
  username                              = include.env.locals.mysql_username
  iam_database_authentication_enabled   = include.env.locals.mysql_iam_database_authentication_enabled
  vpc_security_group_ids                = [dependency.security_group.outputs.security_group_id]
  maintenance_window                    = include.env.locals.mysql_maintenance_window
  backup_window                         = include.env.locals.mysql_backup_window
  create_db_subnet_group                = include.env.locals.mysql_create_db_subnet_group
  subnet_ids                            = dependency.vpc.outputs.private_subnets
  family                                = include.env.locals.mysql_family
  major_engine_version                  = include.env.locals.mysql_major_engine_version
  deletion_protection                   = include.env.locals.mysql_deletion_protection
  skip_final_snapshot                   = include.env.locals.mysql_skip_final_snapshot
  kms_key_id                            = dependency.kms.outputs.key_arn
  tags                                  = include.env.locals.tags
}

dependency "security_group" {
  config_path = "${get_original_terragrunt_dir()}/../rds-mysql-sg"
  
  mock_outputs = {
    security_group_id = "sg-00000000"
  }
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"

  mock_outputs = {
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

skip = include.env.locals.skip_module.rds_mysql