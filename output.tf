output "enabled" {
  description = "Whether AWS Config resources were created (config_parameters.enable)."
  value       = local.config_enable == 1
}

output "s3_bucket_id" {
  description = "Central AWS Config delivery S3 bucket name (log account)."
  value       = try(module.log_bucket[0].bucket_id, null)
}

output "kms_key_arn" {
  description = "KMS key ARN used for AWS Config delivery encryption."
  value       = try(module.kms[0].key_arn, null)
}

output "stackset_name" {
  description = "Name of the StackSet deploying recorders to member accounts."
  value       = try(module.stackset[0].stackset_name, null)
}

output "stackset_id" {
  description = "ID of the StackSet deploying recorders to member accounts."
  value       = try(module.stackset[0].stackset_id, null)
}

output "regions" {
  description = "Regions where AWS Config recorders are deployed (home Region first)."
  value       = local.config_enable == 1 ? concat([local.home_region], [for r in local.regions : r if r != local.home_region]) : []
}

output "management_recorder_names" {
  description = "Map of Region to configuration recorder name in the management account."
  value       = try(module.management_recorder[0].recorder_names, {})
}

output "aggregator_arn" {
  description = "ARN of the organization configuration aggregator (delegated admin account)."
  value       = try(module.organization[0].aggregator_arn, null)
}

output "organization_managed_rule_arns" {
  description = "Map of organization managed rule name to ARN."
  value       = try(module.organization[0].organization_managed_rule_arns, {})
}
