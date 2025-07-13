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

variable "DE_LIJN_API_KEY_REALTIME" {
  type        = string
  description = "The API key for the De Lijn Realtime API."
  sensitive   = true
}

variable "DE_LIJN_API_KEY_STATIC" {
  type        = string
  description = "The API key for the De Lijn Static API."
  sensitive   = true
}