/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* Config | Variable Definition                                         */
/*----------------------------------------------------------------------*/

variable "config_parameters" {
  type        = any
  description = "Organization-wide AWS Config recorders, delivery bucket, KMS, aggregator, and organization rules configuration."
  default     = {}
}

variable "config_defaults" {
  type        = any
  description = "Default values merged into each entry of config_parameters."
  default     = {}
}
