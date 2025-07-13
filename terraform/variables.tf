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