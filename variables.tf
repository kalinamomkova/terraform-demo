variable "resource_group_name" {
  type        = string // тип на променливата
  description = "The name of the resource group"
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group"
}

variable "azurerm_service_plan_name" {
  type        = string
  description = "The app service plan name"
}

variable "app_service_name" {
  type        = string
  description = "The name of our web app"
}

variable "sql_server_name" {
  type        = string
  description = "The name of sql server"
}

variable "sql_database_name" {
  type        = string
  description = "The name of the database"
}

variable "sql_admin_login" {
  type        = string
  description = "The username for sql server"
}

variable "sql_admin_password" {
  type        = string
  description = "Te admin password for sql server"
}

variable "firewall_rule_name" {
  type        = string
  description = "The name of the firewall rule"
}

variable "repo_URL" {
  type        = string
  description = "The url of github repo"
}
