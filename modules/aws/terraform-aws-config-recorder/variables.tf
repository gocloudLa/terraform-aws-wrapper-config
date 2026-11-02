variable "regions" {
  type        = list(string)
  description = "Regions where the recorder, delivery channel and status are created."
}

variable "home_region" {
  type        = string
  description = "Home Region; the only Region that records global resource types."
}

variable "recorder_name" {
  type        = string
  description = "Name of the configuration recorder and delivery channel."
}

variable "role_name" {
  type        = string
  description = "Name of the global recorder IAM role shared by every Region."
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
  description = "KMS key ARN used by the delivery channel; empty disables SSE-KMS on delivery."
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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the IAM role."
  default     = {}
}
