module "kms" {
  source = "./modules/aws/terraform-aws-config-kms"
  count  = local.kms_enable

  providers = { aws = aws.kms }

  description             = try(var.config_parameters.kms.description, "KMS key for AWS Config delivery encryption (${local.common_name})")
  deletion_window_in_days = try(var.config_parameters.kms.deletion_window_in_days, 30)
  enable_key_rotation     = try(var.config_parameters.kms.enable_key_rotation, true)
  alias_name              = try(var.config_parameters.kms.alias_name, "alias/${local.common_name}-config")
  tags                    = merge(local.common_tags, try(var.config_parameters.tags, var.config_defaults.tags, null))

  organization_id = local.organization_id
  log_account_id  = data.aws_caller_identity.log.account_id
  log_region      = data.aws_region.log.region
}

module "log_bucket" {
  source = "./modules/aws/terraform-aws-config-log-bucket"
  count  = local.config_enable

  providers = { aws = aws.log }

  bucket_name       = try(var.config_parameters.log_bucket.bucket_name, "${local.common_name}-config-logs-${data.aws_caller_identity.log.account_id}")
  force_destroy     = try(var.config_parameters.log_bucket.force_destroy, false)
  enable_versioning = try(var.config_parameters.log_bucket.enable_versioning, true)
  tags              = merge(local.common_tags, try(var.config_parameters.tags, var.config_defaults.tags, null))

  s3_key_prefix   = local.s3_key_prefix
  organization_id = local.organization_id
  kms_key_arn     = local.kms_key_arn

  lifecycle_glacier_transition_days = try(var.config_parameters.log_bucket.lifecycle_glacier_transition_days, null)
  lifecycle_expiration_days         = try(var.config_parameters.log_bucket.lifecycle_expiration_days, null)
}

module "stackset" {
  source = "./modules/aws/terraform-aws-config-stackset"
  count  = local.stackset_enable

  providers = { aws = aws.org }

  regions     = local.regions
  home_region = local.home_region

  stackset_name                    = try(var.config_parameters.stackset.name, "${local.common_name}-config-recorder")
  organizational_unit_ids          = try(var.config_parameters.stackset.organizational_unit_ids, [local.root_id])
  max_concurrent_percentage        = try(var.config_parameters.stackset.max_concurrent_percentage, 100)
  failure_tolerance_percentage     = try(var.config_parameters.stackset.failure_tolerance_percentage, 10)
  retain_stacks_on_account_removal = try(var.config_parameters.stackset.retain_stacks_on_account_removal, false)
  tags                             = merge(local.common_tags, try(var.config_parameters.tags, var.config_defaults.tags, null))

  recorder_name                 = local.recorder_name
  role_name                     = local.role_name
  s3_bucket_name                = module.log_bucket[0].bucket_id
  s3_key_prefix                 = local.s3_key_prefix
  kms_key_arn                   = local.kms_key_arn
  include_global_resource_types = try(var.config_parameters.recorder.include_global_resource_types, true)
  recording_frequency           = try(var.config_parameters.recorder.recording_frequency, "CONTINUOUS")
  delivery_frequency            = try(var.config_parameters.recorder.delivery_frequency, "TwentyFour_Hours")
}

module "management_recorder" {
  source = "./modules/aws/terraform-aws-config-recorder"
  count  = local.management_account_enable

  providers = { aws = aws.org }

  regions     = local.regions
  home_region = local.home_region

  recorder_name                 = local.recorder_name
  role_name                     = local.role_name
  s3_bucket_name                = module.log_bucket[0].bucket_id
  s3_key_prefix                 = local.s3_key_prefix
  kms_key_arn                   = local.kms_key_arn
  include_global_resource_types = try(var.config_parameters.recorder.include_global_resource_types, true)
  recording_frequency           = try(var.config_parameters.recorder.recording_frequency, "CONTINUOUS")
  delivery_frequency            = try(var.config_parameters.recorder.delivery_frequency, "TwentyFour_Hours")
  tags                          = merge(local.common_tags, try(var.config_parameters.tags, var.config_defaults.tags, null))
}

module "organization" {
  source = "./modules/aws/terraform-aws-config-organization"
  count  = local.config_enable

  providers = { aws = aws.sec }

  enable_aggregator              = try(var.config_parameters.aggregator.enable, true)
  aggregator_name                = try(var.config_parameters.aggregator.name, "${local.common_name}-org-aggregator")
  aggregator_regions             = local.regions
  organization_managed_rules     = try(var.config_parameters.organization_managed_rules, {})
  organization_conformance_packs = try(var.config_parameters.organization_conformance_packs, {})
  tags                           = merge(local.common_tags, try(var.config_parameters.tags, var.config_defaults.tags, null))

  # Organization rules evaluate against recorders; deploy them first.
  depends_on = [
    module.stackset,
    module.management_recorder,
  ]
}
