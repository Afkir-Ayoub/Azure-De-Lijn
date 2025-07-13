variable "project_name" {
  type        = string
  description = "A short name for the project, used as a prefix."
  default     = "delijn"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
  default     = "West Europe"
}

variable "delijn_api_key_realtime" {
  type        = string
  description = "The API key for the De Lijn Realtime API."
  sensitive   = true
}

variable "delijn_api_key_static" {
  type        = string
  description = "The API key for the De Lijn Static API."
  sensitive   = true
}