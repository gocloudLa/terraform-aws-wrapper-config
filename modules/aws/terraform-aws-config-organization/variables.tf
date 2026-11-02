variable "enable_aggregator" {
  type        = bool
  description = "Create the organization-wide configuration aggregator."
  default     = true
}

variable "aggregator_name" {
  type        = string
  description = "Name of the organization configuration aggregator."
}

variable "aggregator_regions" {
  type        = list(string)
  description = "Regions aggregated by the organization aggregator (the Regions with recorders)."
  default     = []
}

variable "organization_managed_rules" {
  type        = any
  description = "Map of organization managed Config rules keyed by rule name."
  default     = {}
}

variable "organization_conformance_packs" {
  type        = any
  description = "Map of organization conformance packs keyed by pack name."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to taggable resources."
  default     = {}
}
