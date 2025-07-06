terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }

  backend "azurerm" {

  }
}

provider "azuredevops" {
  org_service_url       = var.org_service_url
  personal_access_token = var.azure_devops_pat
}
