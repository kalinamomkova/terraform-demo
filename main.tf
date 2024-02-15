terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

#Generate random integer
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

#Generate azure resource group
resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group_name}-${random_integer.ri.result}"
  location = var.resource_group_location
}

#Generate azure app service plan
resource "azurerm_service_plan" "asp" {
  name                = "${var.azurerm_service_plan_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

#Generate linux web app
resource "azurerm_linux_web_app" "alwapp" {
  name                = "${var.app_service_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.azmssqlServer.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.azurerm_mssql_database.name};User ID=${azurerm_mssql_server.azmssqlServer.administrator_login};Password=${azurerm_mssql_server.azmssqlServer.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
}

resource "azurerm_mssql_server" "azmssqlServer" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_firewall_rule" "example" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.azmssqlServer.id
  start_ip_address = "0.0.0.0" // this means that it allows other Azure resources to access the server
  end_ip_address   = "0.0.0.0" // this means that it allows other Azure resources to access the server
}

resource "azurerm_mssql_database" "azurerm_mssql_database" {
  name           = "${var.sql_database_name}${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.azmssqlServer.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "S0"
  zone_redundant = false
}

#Upload project from github in azure
resource "azurerm_app_service_source_control" "aasac" {
  app_id                 = azurerm_linux_web_app.alwapp.id
  repo_url               = var.repo_URL
  branch                 = "main"
  use_manual_integration = true
}