locals {
  env     = "dev"
  project = "codefactory"
  domain  = "config.hu"
  aws_id  = "500286922458"

  project_version = "v1.0.104"
  iam_role        = "arn:aws:iam::${local.aws_id}:role/terragrunt"

  slack_api_url = ""
  slack_channel = ""

  # Skip modules
  skip_module = {
    acm                           = false
    cloudfront                    = false
    ec2_bastion                   = false
    ec2_instance                  = false
    ecr                           = false
    eks                           = false
    eks_autoscaler                = false
    eks_alb                       = false
    eks_alb_log                   = false
    eks_cloudwatch_logs           = false
    eks_cloudwatch_logs_iam_role  = false
    eks_cloudwatch_logs_policy    = false
    fluentbit_irsa                = false
    fluentbit_policy              = false
    helm_release                  = false
    iam_group                     = true
    iam_system_user               = false
    iam_user                      = true
    irsa                          = false
    kms                           = false

    observability_logs_s3         = false
    observability_logs_s3_user    = false
    observability_metrics_s3      = false
    observability_metrics_s3_user = false
    observability_traces_s3       = false
    observability_traces_s3_user  = false

    observability_fluentbit      = false
    observability_grafana        = false
    observability_loki           = false
    observability_otel_collector = false
    observability_prometheus     = false
    observability_tempo          = false

    opensearch              = true
    rabbitmq                = false
    rds_aurora              = false
    rds_aurora_experimental = true
    rds_mysql               = false
    rds_mysql_sg            = false
    redis                   = false
    route53_records         = false
    route53_zone            = true
    ses                     = false
    sns                     = false
    vpc                     = false
  }

  # EC2 instance variables
  ec2_instance_name       = "${local.env}-${local.project}-ec2"
  ec2_instance_type       = "t2.micro"
  ec2_instance_key_name   = "user1"
  ec2_instance_monitoring = true

  # Cloudfront variables
  cloudfront_distribution_name                = "test-app-staging.globalvet.com"
  cloudfront_distribution_aliases             = ["www.config.hu"]
  cloudfront_distribution_parent_zone_name    = "config.hu"
  cloudfront_distribution_acm_certificate_arn = "arn:aws:acm:${local.region}:${local.aws_id}:certificate/00000000-0000-0000-0000-000000000000"
  cloudfront_distribution_allowed_methods     = ["HEAD", "GET"]
  cloudfront_distribution_cached_methods      = ["HEAD", "GET"]

  # Route53 variables
  route53_zones = {
    confighu = {
      domain_name               = "config.hu"
      zone_id                   = "Z054873227CA6AOK4PYSW"
      subject_alternative_names = ["www.${local.domain}"]

      route53_records = {
        record1 = {
          name    = "test-record-1"
          type    = "A"
          ttl     = 3600
          records = ["10.10.10.10"]
        }

        record2 = {
          name    = "test-record-2"
          type    = "A"
          ttl     = 3600
          records = ["10.10.10.10"]
        }
      }

      tags = "${local.tags}"
    }
  }

  # Bastion variables
  bastion_suffix        = "bastion"
  bastion_instance_type = "t3.nano"

  # KMS variabless
  kms_customer_master_key_spec = "SYMMETRIC_DEFAULT"
  kms_key_usage                = "ENCRYPT_DECRYPT"
  kms_key_administrators       = ["${local.iam_role}"]

  # VPC variables
  vpc_cidr                             = "10.0.0.0/16"
  vpc_nat_gateway                      = true
  vpc_single_nat_gateway               = true
  vpc_create_egress_only_igw           = true
  vpc_enable_dns_hostnames             = true
  vpc_enable_dns_support               = true
  region                               = "eu-west-2"
  availability_zone                    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  # Redis variables
  redis_name                                 = "${local.env}-${local.project}-redis"
  redis_cluster_size                         = 1
  redis_instance_type                        = "cache.t2.micro"
  redis_engine_version                       = "6.2"
  redis_family                               = "redis6.x"
  redis_apply_immediately                    = true
  redis_automatic_failover_enabled           = false
  redis_at_rest_encryption_enabled           = true
  redis_transit_encryption_enabled           = true
  redis_maintenance_window                   = "wed:03:00-wed:04:00"
  redis_security_group_create_before_destroy = true
  redis_security_group_name                  = "${local.env}-${local.project}-redis-sg"
  redis_allow_all_egress                     = false

  # RabbitMQ variables
  rabbit_name                                 = "${local.env}-${local.project}-mq-broker"
  rabbit_mq_admin_user                        = "user"
  rabbit_mq_admin_password                    = "password"
  rabbit_apply_immediately                    = true
  rabbit_auto_minor_version_upgrade           = true
  rabbit_deployment_mode                      = "ACTIVE_STANDBY_MULTI_AZ"
  rabbit_engine_type                          = "ActiveMQ"
  rabbit_engine_version                       = "5.15.0"
  rabbit_host_instance_type                   = "mq.t3.micro"
  rabbit_publicly_accessible                  = false
  rabbit_general_log_enabled                  = true
  rabbit_audit_log_enabled                    = true
  rabbit_maintenance_day_of_week              = "SUNDAY"
  rabbit_maintenance_time_of_day              = "03:00"
  rabbit_maintenance_time_zone                = "UTC"
  rabbit_security_group_create_before_destroy = true
  rabbit_security_group_name                  = "${local.env}-${local.project}-rabbitmq-sg"
  rabbit_additional_security_group_rules      = []
  rabbit_allow_all_egress                     = false
  rabbit_allowed_ingress_ports                = [8162, 5671]
  rabbit_encryption_enabled                   = true
  rabbit_use_aws_owned_key                    = false

  # RDS MySQL variables
  mysql_identifier                          = "${local.env}-${local.project}-${local.mysql_engine}"
  mysql_engine                              = "mysql"
  mysql_engine_version                      = "8.0"
  mysql_instance_class                      = "db.t3.small"
  mysql_allocated_storage                   = 5
  mysql_db_name                             = "testdb"
  mysql_username                            = "user"
  mysql_password                            = "password"
  mysql_iam_database_authentication_enabled = true
  mysql_maintenance_window                  = "Mon:00:00-Mon:03:00"
  mysql_backup_window                       = "03:00-06:00"
  mysql_create_db_subnet_group              = true
  mysql_family                              = "mysql8.0"
  mysql_major_engine_version                = "8.0"
  mysql_deletion_protection                 = false
  mysql_skip_final_snapshot                 = true

  # Aurora MySQL variables
  rds_aurora_name                             = "aurora-db-mysql"
  rds_aurora_engine                           = "aurora-mysql"
  rds_aurora_engine_version                   = "8.0.mysql_aurora.3.03.0"
  rds_aurora_cluster_family                   = "aurora-mysql8.0"
  rds_aurora_instance_type                    = "db.t3.medium"
  rds_aurora_storage_encrypted                = true
  rds_aurora_apply_immediately                = true
  rds_aurora_rds_monitoring_interval          = 15
  rds_aurora_enhanced_monitoring_role_enabled = true
  rds_aurora_retention_period                 = 14
  rds_aurora_subnet_group_name                = "${local.rds_aurora_name}-db-subnets"

  rds_aurora_parameters = [
    {
      name         = "max_connections"
      value        = "1024"
      apply_method = "immediate"
    },
  ]

  rds_aurora_admin_user          = "admin"
  rds_aurora_admin_password      = "adminadmin"
  rds_aurora_deletion_protection = true
  rds_aurora_skip_final_snapshot = false
  rds_aurora_cluster_size        = 1

  # ECR repository variables
  ecr_repositories = {
    ecr1 = {
      repository_name                   = "${local.project}"
      repository_type                   = "private"
      repository_read_write_access_arns = []
      tags                              = "${local.tags}"
    }

    ecr2 = {
      repository_name                   = "${local.project}-2"
      repository_type                   = "private"
      repository_read_write_access_arns = []
      tags                              = "${local.tags}"
    }
  }

  # IRSA variables
  irsa_role_name                     = "${local.env}-${local.project}-ebs-csi"
  irsa_attach_ebs_csi_policy         = true
  irsa_namespace_service_accounts    = ["kube-system:ebs-csi-controller-sa"]
  irsa_ebs_csi_kms_cmk_ids           = []
  irsa_external_secrets_kms_key_arns = ["arn:aws:kms:*:*:key/*"]

  # IRSA-fluentbit variables
  fluentbit_irsa_role_name                  = "${local.env}-${local.project}-fluentbit"
  fluentbit_irsa_namespace_service_accounts = ["kube-system:aws-for-fluent-bit"]

  # EKS variables
  eks_cluster_name                    = "${local.project}"
  eks_cluster_version                 = "1.29"
  eks_log_types                       = ["audit", "api", "authenticator"]
  eks_cluster_endpoint_public_access  = true
  eks_cluster_endpoint_private_access = true

  # List of CIDR blocks which can access the Amazon EKS public API server endpoint
  eks_cluster_endpoint_public_access_cidrs = ["84.0.244.179/32", "0.0.0.0/0"]

  eks_coredns_addon_version            = "v1.11.1-eksbuild.9"
  eks_kube_proxy_addon_version         = "v1.29.3-eksbuild.2"
  eks_vpc_cni_addon_version            = "v1.18.1-eksbuild.3"
  eks_aws_ebs_csi_driver_addon_version = "v1.31.0-eksbuild.1"
  eks_aws_ebs_csi_driver_role_arn      = "arn:aws:iam::${local.aws_id}:role/${local.env}-${local.project}-ebs-csi"

  eks_create_cloudwatch_log_group            = true
  eks_cloudwatch_log_group_retention_in_days = 90

  # EKS nodegroup variables
  eks_nodegroup_desired_size        = 2
  eks_nodegroup_min_size            = 1
  eks_nodegroup_max_size            = 3
  eks_nodegroup_disk_size           = 50
  eks_nodegroup_instance_types      = ["t3.small"]
  eks_nodegroup_capacity_type       = "ON_DEMAND"
  eks_nodegroup_ami_release_version = "1.29.3-20240522"

  # EKS allowed users
  eks_access_entries = {
    vighzoltan = {
      principal_arn     = "arn:aws:iam::${local.aws_id}:user/vigh.zoltan"
      kubernetes_groups = ["eks-admin"]
      policy_associations = {
        clusteradmin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
    pappcsenge = {
      principal_arn     = "arn:aws:iam::${local.aws_id}:user/papp.csenge"
      kubernetes_groups = ["eks-admin"]
      policy_associations = {
        clusteradmin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
    varghalaszlo = {
      principal_arn     = "arn:aws:iam::${local.aws_id}:user/vargha.laszlo"
      kubernetes_groups = ["eks-admin"]
      policy_associations = {
        clusteradmin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Name            = "${local.env}-${local.project}"
    Environment     = "${local.env}"
    Project-version = "${local.project_version}"
  }

 
  # Helm release
  helm_releases = {
    # fluentbit = {
    #   repository           = "https://fluent.github.io/helm-charts"
    #   chart                = "fluent-bit"
    #   chart_version        = "0.34.2"
    #   kubernetes_namespace = "kube-system"

    #   values = [
    #     <<EOF
    #     serviceAccount:
    #       create: true
    #       annotations: 
    #         eks.amazonaws.com/role-arn: arn:aws:iam::${local.aws_id}:role/${local.env}-${local.project}-fluentbit
    #       name: aws-for-fluent-bit

    #     config:
    #       inputs: |
    #         [INPUT]
    #             Name cpu
    #             Tag cpu

    #       outputs: |
    #         [OUTPUT]
    #             Name opensearch
    #             Match *
    #             Host opensearch-cluster-master
    #             Port 9200
    #             Index my_index
    #             Type my_type
    #     EOF   
    #   ]
    #   tags                 = "${local.tags}"      
    # }

    # opensearch = {
    #   repository           = "https://opensearch-project.github.io/helm-charts/"
    #   chart                = "opensearch"
    #   chart_version        = "2.13.3"
    #   kubernetes_namespace = "kube-system"
    #   values               = [
    #     <<EOF
    #     replicas: 1
    #     EOF
    #     ,
    #   ]

    #   tags = "${local.tags}"
    # }

    # nats = {
    #   repository           = "https://nats-io.github.io/k8s/helm/charts/"
    #   chart                = "nats"
    #   chart_version        = "0.19.16"
    #   create_namespace     = true
    #   kubernetes_namespace = "infra"

    #   values = [
    #     <<EOF
    #     cluster:
    #       enabled: true
    #       replicas: 3
    #     EOF
    #     ,
    #   ]

    #   tags = "${local.tags}"
    # }

    reloader = {
      repository           = "https://stakater.github.io/stakater-charts"
      chart                = "reloader"
      chart_version        = "1.0.62"
      create_namespace     = true
      kubernetes_namespace = "infra"
      tags                 = "${local.tags}"
    }

    # signoz = {
    #   repository           = "https://charts.signoz.io"
    #   chart                = "signoz"
    #   chart_version        = "0.17.0"
    #   create_namespace     = true
    #   kubernetes_namespace = "observability"

    #   values = [
    #     <<EOF
    #     global:
    #         storageClass: gp2
    #         cloud: aws

    #     clickhouse:
    #         installCustomStorageClass: true
    #     EOF
    #     ,
    #   ]

    #   tags = "${local.tags}"
    # }
  }

  # EKS alb variables
  alb_helm_chart_name         = "aws-load-balancer-controller"
  alb_helm_chart_release_name = "aws-load-balancer-controller"
  alb_helm_chart_repository   = "https://aws.github.io/eks-charts"
  alb_helm_chart_version      = "1.4.4"
  alb_kubernetes_namespace    = "kube-system"
  alb_service_account_name    = "aws-alb-ingress-controller"


  # EKS Cloudwatch fluentbit variables
  eks_cloudwatch_helm_chart_repository = "https://aws.github.io/eks-charts"
  eks_cloudwatch_helm_chart_name       = "aws-for-fluent-bit"
  eks_cloudwatch_helm_chart_version    = "0.1.28"
  eks_cloudwatch_kubernetes_namespace  = "kube-system"
  eks_cloudwatch_atomic                = true
  eks_cloudwatch_cleanup_on_fail       = true
  eks_cloudwatch_values                = [
    <<EOF
        serviceAccount:
          create: true
          annotations: 
            eks.amazonaws.com/role-arn: arn:aws:iam::500286922458:role/dev-codefactory-cloudwatch-logs
          name: aws-for-fluent-bit

        cloudWatchLogs:
          region: "eu-west-2"
          logRetentionDays: 1
    EOF
  ]

  # EKs CLoundwatch policy variables
  eks_cloudwatch_policy_name = "${local.env}-${local.project}-cloudwatch-policy"
  eks_cloudwatch_policy_description = "Permissions required to use AmazonCloudWatchAgent on servers"
  eks_cloudwatch_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "cloudwatch:PutMetricData",
              "ec2:DescribeVolumes",
              "ec2:DescribeTags",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams",
              "logs:DescribeLogGroups",
              "logs:CreateLogStream",
              "logs:CreateLogGroup",
              "logs:PutRetentionPolicy"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "ssm:GetParameter"
          ],
          "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
      }
  ]
}
EOF

  # EKS external dns variables
  external_dns_helm_chart_version    = "6.22.0"
  external_dns_irsa_role_name_prefix = "irsa"
  external_dns_values                = yamlencode({
    "LogLevel" : "debug"
    "provider" : "aws"
    "registry" : "txt"
    "txtOwnerId" : "eks-cluster"
    "txtPrefix" : "external-dns"
    "policy" : "sync"
    "publishInternalServices" : "true"
    "triggerLoopOnEvent" : "true"
    "interval" : "5s"
    "podLabels" : {
      "app" : "aws-external-dns-helm"
    }
  })

  # EKS autoscaler variables
  autoscaler_helm_chart_version = "9.29.1"
  autoscaler_namespace          = "kube-system"

  # EKS cloudwatch logs IRSA variables
  eks_cloudwatch_logs_irsa_role_name                      = "${local.env}-${local.project}-cloudwatch-logs"
  eks_cloudwatch_logs_irsa_namespace_service_accounts     = ["kube-system:aws-for-fluent-bit"]
  eks_cloudwatch_logs_irsa_role_policy_arns               = {policy="arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"}

  # Observability
  observability_create_namespace = true
  observability_namespace        = "observability"
  observability_atomic           = true
  observability_cleanup_on_fail  = true
  observability_force_update     = true
  observability_wait             = false

  # Observability buckets
  observability_bucket_force_destroy = true

  observability_bucket_lifecycle_policy = [
    {
      id = "rule-1"

      expiration = {
        days = 14
      }

      status = "Enabled"
    },
  ]

  observability_s3_user_create_iam_access_key = true
  observability_s3_user_ssm_enabled           = false
  observability_s3_user_force_destroy         = true

  observability_s3_user_actions = [
    "s3:ListBucket",
    "s3:GetBucketLocation",
    "s3:ListBucketMultipartUploads",
    "s3:PutObject",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:AbortMultipartUpload",
    "s3:ListMultipartUploadParts",
  ]

  # Observability - log bucket
  observability_logs_bucket_name       = "observability-logs-bucket"
  observability_logs_s3_user_name      = "observability-logs-bucket-user"
  observability_logs_s3_user_resources = ["arn:aws:s3:::${local.observability_logs_bucket_name}/*", "arn:aws:s3:::${local.observability_logs_bucket_name}"]

  # Observability - metrics bucket
  observability_metrics_bucket_name       = "observability-metrics-bucket"
  observability_metrics_s3_user_name      = "observability-metrics-bucket-user"
  observability_metrics_s3_user_resources = ["arn:aws:s3:::${local.observability_metrics_bucket_name}/*", "arn:aws:s3:::${local.observability_metrics_bucket_name}"]

  # Observability - trace bucket 
  observability_traces_bucket_name       = "observability-traces-bucket"
  observability_traces_s3_user_name      = "observability-traces-bucket-user"
  observability_traces_s3_user_resources = ["arn:aws:s3:::${local.observability_traces_bucket_name}/*", "arn:aws:s3:::${local.observability_traces_bucket_name}"]

  # Observablilty - Grafana helm chart varibles
  grafana_helm_chart_repository = "https://grafana.github.io/helm-charts"
  grafana_helm_chart_name       = "grafana"
  grafana_helm_chart_version    = "6.57.4"
  grafana_namespace             = "grafana"

  # Observability - Otel collector variables
  otel_collector_helm_chart_repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  otel_collector_helm_chart_name       = "opentelemetry-collector"
  otel_collector_helm_chart_version    = "0.62.1"

  # Observability - Prometheus helm chart variables
  prometheus_helm_chart_repository = "https://prometheus-community.github.io/helm-charts/"
  prometheus_helm_chart_name       = "kube-prometheus-stack"
  prometheus_helm_chart_version    = "45.27.2"

  # Observability - Tempo helm chart variables
  tempo_helm_chart_repository = "https://grafana.github.io/helm-charts"
  tempo_helm_chart_name       = "tempo"
  tempo_helm_chart_version    = "1.3.1"

  # Observability - Fluentbit helm chart variables
  fluentbit_helm_chart_repository = "https://fluent.github.io/helm-charts"
  fluentbit_helm_chart_name       = "fluent-bit"
  fluentbit_helm_chart_version    = "0.34.2"
  fluentbit_namespace             = "fluent-bit"

  # Observability - Loki helm chart variables
  loki_helm_chart_repository = "https://grafana.github.io/helm-charts"
  loki_helm_chart_name       = "loki"
  loki_helm_chart_version    = "3.0.1"

  # SES variables
  ses_user_enabled  = false
  ses_group_enabled = false
  ses_verify_domain = true

  # s3 buckets
  s3_buckets = {
    clinic-svc-staging = {
      name             = "globalvet-test-bucket-00"
      object_ownership = "BucketOwnerEnforced"

      server_side_encryption_configuration = {
        rule = {
          bucket_key_enabled = true
        }
      }

      tags = "${local.tags}"
    }
  }

  # IAM users
  iam_users = {
    example-user = {
      name = "example-user"
      tags = "${local.tags}"
    }
  }

  # IAM user groups
  iam_groups = {
    example_user_group = {
      name = "example-group"
      group_users = ["example-user"]
      custom_group_policy_arns = []
      tags = "${local.tags}"
    }
  }

  # IAM system users
  iam_system_users = {
    sns_user = {
      name = "${local.project}-sns"

      policy_arns_map = {
        sns = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
      }

      tags = "${local.tags}"
    }

    ses_user = {
      name = "${local.project}-ses"

      policy_arns_map = {
        logs = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      }

      inline_policies_map = {
        s3 = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "Statement1",
"Effect": "Allow",
"Action": [
"s3:PutObject",
"s3:GetObjectAcl",
"s3:GetObject",
"s3:ListBucket",
"s3:PutObjectAcl"],
"Resource": [
"arn:aws:s3:::bucket_name/*",
"arn:aws:s3:::bucket_name/"]
}
]
}
      EOF
      }

      tags = "${local.tags}"
    }
  }
}