terraform {
  source = "git.com:terraform-aws-modules/terraform-aws-security-group.git?ref=v5.1.1"
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
  name                                  = "${include.env.locals.env}-${include.env.locals.project}-rds-sg"
  description                           = "RDS MySQL security group"
  vpc_id                                = dependency.vpc.outputs.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      description              = "MYSQL allow from Bastion"
      source_security_group_id = dependency.bastion.outputs.security_group_id
    },
    {
      rule                     = "mysql-tcp"
      description              = "MYSQL allow from EKS"
      source_security_group_id = dependency.eks.outputs.node_security_group_id
    },
  ]

  tags                   = include.env.locals.tags  
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000"
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

skip = include.env.locals.skip_module.rds_mysql_sg