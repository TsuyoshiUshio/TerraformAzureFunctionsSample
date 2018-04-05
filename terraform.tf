# Service Principle
variable "subscription_id" {}

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Resource Group

variable "resource_group" {}
variable "location" {}
variable "environment" {}

# Function App

variable "function_app_name" {}

provider "azurerm" {
  # Service Principle
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "${var.resource_group}"
  location = "${var.location}"

  tags {
    environment = "${var.environment}"
  }
}

resource "random_string" "test" {
  length  = 8
  special = false
}

resource "azurerm_storage_account" "test" {
  name                     = "${var.function_app_name}${lower(random_string.test.result)}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${azurerm_resource_group.test.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = ["azurerm_resource_group.test"]
}

resource "azurerm_app_service_plan" "test" {
  name                = "${var.function_app_name}plan"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  depends_on = ["azurerm_resource_group.test"]
}

resource "azurerm_application_insights" "test" {
  name                = "${var.function_app_name}-appinsights"
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.test.name}"
  application_type    = "Web"
}

resource "azurerm_function_app" "test" {
  name                      = "${var.function_app_name}"
  location                  = "${azurerm_resource_group.test.location}"
  resource_group_name       = "${azurerm_resource_group.test.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.test.id}"
  storage_connection_string = "${azurerm_storage_account.test.primary_connection_string}"
  version                   = "beta"

  app_settings {
    //  WEBSITE_USE_ZIP                = "https://github.com/TsuyoshiUshio/EndPoint/releases/download/0.0.1/endpoint.zip" // Currently doesn't work for the known issue.
    APPINSIGHTS_INSTRUMENTATIONKEY = "${azurerm_application_insights.test.instrumentation_key}"
  }

  provisioner "local-exec" {
    command = "az functionapp deployment source config-zip -g ${azurerm_resource_group.test.name} -n ${var.function_app_name} --src ./function.zip"
  }

  depends_on = ["azurerm_storage_account.test", "azurerm_app_service_plan.test", "azurerm_application_insights.test"]
}
