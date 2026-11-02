/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

# variable "metadata" {
#   type = any
# }

/*----------------------------------------------------------------------*/
/* Config | Variable Definition                                         */
/*----------------------------------------------------------------------*/
variable "config_parameters" {
  type        = any
  description = "Config parameteres to configure the wrapper module"
  default     = {}
}

variable "config_defaults" {
  type        = any
  description = "Config default parameteres for the wrapper module"
  default     = {}
}
