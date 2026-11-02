variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for AWS Config delivery."
}

variable "force_destroy" {
  type        = bool
  description = "Allow bucket destruction when non-empty."
  default     = false
}

variable "enable_versioning" {
  type        = bool
  description = "Enable S3 versioning on the log bucket."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the bucket."
  default     = {}
}

variable "s3_key_prefix" {
  type        = string
  description = "S3 key prefix used by the delivery channels (empty means objects land under AWSLogs/)."
  default     = ""
}

variable "organization_id" {
  type        = string
  description = "Organization ID (o-xxxxxxxxxx) allowed to deliver to the bucket."
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for default SSE-KMS encryption; empty uses SSE-S3."
  default     = ""
}

variable "lifecycle_glacier_transition_days" {
  type        = number
  description = "Transition current objects to GLACIER after N days (null skips)."
  default     = null
}

variable "lifecycle_expiration_days" {
  type        = number
  description = "Expire current objects after N days (null skips)."
  default     = null
}
