output "aggregator_arn" {
  description = "ARN of the organization configuration aggregator."
  value       = try(aws_config_configuration_aggregator.organization[0].arn, null)
}

output "aggregator_role_arn" {
  description = "ARN of the IAM role used by the aggregator."
  value       = try(aws_iam_role.aggregator[0].arn, null)
}

output "organization_managed_rule_arns" {
  description = "Map of organization managed rule name to ARN."
  value       = { for k, v in aws_config_organization_managed_rule.this : k => v.arn }
}

output "organization_conformance_pack_arns" {
  description = "Map of organization conformance pack name to ARN."
  value       = { for k, v in aws_config_organization_conformance_pack.this : k => v.arn }
}
