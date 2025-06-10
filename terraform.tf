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

  client_id                   = "4ed988e3-800a-485a-ba56-dc3f0b6a7073"
  client_secret     =          "c3w8Q~drbkWEsQf0QHl9S.4pY4LdeqspNKEsDar7"
  tenant_id                   = "3e8e0241-e270-4b03-ae50-0c006fcb767b"
  subscription_id             = "d280007c-c6c9-4cfb-bcef-0bb98fff82cd"
  
}
