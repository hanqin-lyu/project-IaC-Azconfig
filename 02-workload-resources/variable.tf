variable "location" {
  type        = string
  default     = "australiaeast"
  description = "Location of the resources."
}
variable "subscription_id" {
  type        = string
  default     = "11111111-1111-1111-1111-111111111111"
  description = "ID of the Azure subscription."
}
variable "tenant_id" {
  type        = string
  default     = "11111111-1111-1111-1111-111111111111"
  description = "ID of the Azure tenant."
}

variable "resource_group_name" {
  type        = string
  default     = "rg"
  description = "Name of the resource group."
}

variable "project_name" {
  type        = string
  description = "Name of the project."
  default     = "project-name"
}

variable "environment" {
  type        = string
  default     = "def-env"
  description = "Environment name."
}

variable "sql_admin_username" {
  type    = string
  default = "azsqladmin"
}

variable "sql_admin_password" {
  type        = string
  default     = "Pswd1234!" # Replace with a secure password
  description = "Password for the SQL admin user."
  sensitive   = true #to avoid exposing the password in logs or state files
}
