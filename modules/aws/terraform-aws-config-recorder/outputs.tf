output "recorder_names" {
  description = "Map of Region to configuration recorder name."
  value       = { for k, v in aws_config_configuration_recorder.this : k => v.name }
}

output "role_arn" {
  description = "ARN of the recorder IAM role."
  value       = aws_iam_role.this.arn
}
