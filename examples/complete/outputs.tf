output "enabled" {
  description = "Whether the wrapper created AWS Config resources."
  value       = module.wrapper_config.enabled
}

output "s3_bucket_id" {
  value = module.wrapper_config.s3_bucket_id
}

output "kms_key_arn" {
  value = module.wrapper_config.kms_key_arn
}

output "stackset_name" {
  value = module.wrapper_config.stackset_name
}

output "stackset_id" {
  value = module.wrapper_config.stackset_id
}

output "regions" {
  value = module.wrapper_config.regions
}

output "management_recorder_names" {
  value = module.wrapper_config.management_recorder_names
}

output "aggregator_arn" {
  value = module.wrapper_config.aggregator_arn
}

output "organization_managed_rule_arns" {
  value = module.wrapper_config.organization_managed_rule_arns
}
