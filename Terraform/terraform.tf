terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.30.0"
    }
  }
}

provider "azurerm" {
  features {}

  #client_id                   = $env:ARM_CLIENT_ID
  #client_secret               = $env:ARM_CLIENT_SECRET
  #tenant_id                   = $env:ARM_TENANT_ID
  #subscription_id             = $env:ARM_SUBSCRIPTION_ID
  
}
