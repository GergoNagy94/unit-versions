terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-bastion-server.git?ref=0.31.1"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  name                              = "${include.env.locals.env}-${include.env.locals.project}-${include.env.locals.bastion_suffix}"
  instance_type                     = include.env.locals.bastion_instance_type
  vpc_id                            = dependency.vpc.outputs.vpc_id
  subnets                           = dependency.vpc.outputs.public_subnets
  ssm_enabled                       = true
  associate_public_ip_address       = true
  security_group_enabled            = true

  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  
  tags                              = include.env.locals.tags
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000"
    public_subnets = [
      "subnet-00000003",
      "subnet-00000004",
      "subnet-00000005",
    ]
  }
}

skip = include.env.locals.skip_module.ec2_bastion