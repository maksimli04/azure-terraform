terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = "maksim-sandbox"
  location = "swedencentral"
  tags = {
    environment = "dev"
    source = "Terraform"
  }
}