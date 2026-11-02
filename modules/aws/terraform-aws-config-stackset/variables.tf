variable "regions" {
  type        = list(string)
  description = "Regions where stack instances (recorders) are deployed."
}

variable "home_region" {
  type        = string
  description = "Home Region; the only Region that records global resource types."
}

variable "stackset_name" {
  type        = string
  description = "Name of the CloudFormation StackSet."
}

variable "organizational_unit_ids" {
  type        = list(string)
  description = "Organization root or OU IDs targeted by the StackSet."
}

variable "recorder_name" {
  type        = string
  description = "Name of the configuration recorder and delivery channel in member accounts."
}

variable "role_name" {
  type        = string
  description = "Base name of the recorder IAM role in member accounts (the Region is appended)."
}

variable "s3_bucket_name" {
  type        = string
  description = "Central S3 bucket receiving AWS Config deliveries."
}

variable "s3_key_prefix" {
  type        = string
  description = "S3 key prefix for delivered objects."
  default     = ""
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN used by the delivery channels; empty disables SSE-KMS on delivery."
  default     = ""
}

variable "include_global_resource_types" {
  type        = bool
  description = "Record global resource types (IAM) in the home Region."
  default     = true
}

variable "recording_frequency" {
  type        = string
  description = "Recording frequency: CONTINUOUS or DAILY."
  default     = "CONTINUOUS"

  validation {
    condition     = contains(["CONTINUOUS", "DAILY"], var.recording_frequency)
    error_message = "recording_frequency must be CONTINUOUS or DAILY."
  }
}

variable "delivery_frequency" {
  type        = string
  description = "Configuration snapshot delivery frequency."
  default     = "TwentyFour_Hours"
}

variable "max_concurrent_percentage" {
  type        = number
  description = "Maximum percentage of accounts deployed concurrently."
  default     = 100
}

variable "failure_tolerance_percentage" {
  type        = number
  description = "Percentage of account failures tolerated per Region before the operation stops."
  default     = 10
}

variable "retain_stacks_on_account_removal" {
  type        = bool
  description = "Keep stack resources in accounts removed from the targeted OUs."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the StackSet."
  default     = {}
}
