output "stackset_name" {
  description = "Name of the StackSet."
  value       = aws_cloudformation_stack_set.this.name
}

output "stackset_id" {
  description = "ID of the StackSet."
  value       = aws_cloudformation_stack_set.this.stack_set_id
}

output "stackset_arn" {
  description = "ARN of the StackSet."
  value       = aws_cloudformation_stack_set.this.arn
}
