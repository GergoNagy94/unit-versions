terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=6.0.1"
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
  name                   = include.env.locals.ec2_instance_name
  instance_type          = include.env.locals.ec2_instance_type
  key_name               = include.env.locals.ec2_instance_key_name
  monitoring             = include.env.locals.ec2_instance_monitoring
  vpc_security_group_ids = [dependency.vpc.outputs.default_security_group_id]
  subnet_id              = dependency.vpc.outputs.private_subnets[0]

  tags = include.env.locals.tags
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
    default_security_group_id = "sg-000000"
  }
}


skip = include.env.locals.skip_module.ec2_instance

