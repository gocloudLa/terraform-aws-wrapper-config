locals {
  config_enable = try(var.config_parameters.enable, false) ? 1 : 0

  kms_enable                = local.config_enable == 1 && try(var.config_parameters.kms.enable, true) ? 1 : 0
  stackset_enable           = local.config_enable == 1 && try(var.config_parameters.stackset.enable, true) ? 1 : 0
  management_account_enable = local.config_enable == 1 && try(var.config_parameters.management_account.enable, true) ? 1 : 0

  organization_id = local.config_enable == 1 ? data.aws_organizations_organization.this[0].id : null
  root_id         = local.config_enable == 1 ? data.aws_organizations_organization.this[0].roots[0].id : null

  # Home Region = aws.org provider Region; global resource types (IAM) are recorded only there.
  home_region = data.aws_region.org.region
  regions     = distinct(try(var.config_parameters.regions, [local.home_region]))

  s3_key_prefix = try(var.config_parameters.s3_key_prefix, "config")
  recorder_name = try(var.config_parameters.recorder.name, "${local.common_name}-config-recorder")
  role_name     = try(var.config_parameters.recorder.role_name, "${local.common_name}-config-recorder")
  kms_key_arn   = local.kms_enable == 1 ? module.kms[0].key_arn : ""
}
