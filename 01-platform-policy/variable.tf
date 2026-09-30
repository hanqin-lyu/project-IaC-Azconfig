variable "resource_group_location" {
  type        = string
  default     = "australiaeast"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "rg"
  description = "Name of the resource group."
}

variable "scope" {
  type        = string
  default     = ""
  description = "Scope of the policy assignment."
}