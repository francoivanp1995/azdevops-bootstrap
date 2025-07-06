#!/bin/bash

set -euo pipefail

#Variables
TEAM="devops"
PURPOSE="bootstrap"
ENV="dev"
LOCATION="eastus"
RESOURCE_GROUP_NAME="rg-tf-$PURPOSE"
STORAGE_ACCOUNT_NAME="st$PURPOSE$TEAM$RANDOM"
CONTAINER_NAME="tfstate"
KEY_VAULT_NAME="kvtf$PURPOSE$TEAM$RANDOM"
SP_NAME="spn-terraform-$PURPOSE"
SP_SECRET_NAME="spn-tf-creds"
AZURE_CONFIG_PATH=".azure.conf"


SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az account set --subscription "$SUBSCRIPTION_ID"

echo "Creating resource group.. $RESOURCE_GROUP_NAME"
az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION" --output none

echo "Creating storage account.. $STORAGE_ACCOUNT_NAME"
az storage account create \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --output none

ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --query "[0].value" -o tsv)

echo "Creando container: $CONTAINER_NAME"
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --account-key "$ACCOUNT_KEY" \
  --output none

echo "Creating Key Vault: $KEY_VAULT_NAME"
az keyvault create \
  --name "$KEY_VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --enable-purge-protection true \
  --output none

echo "Creating Service Principal: $SP_NAME"
SPN_JSON=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role Contributor \
  --scopes /subscriptions/$(az account show --query id -o tsv) \
  --sdk-auth)

echo "Storing SPN in Key Vault as secret: $SP_SECRET_NAME"
az keyvault secret set \
  --vault-name "$KEY_VAULT_NAME" \
  --name "$SP_SECRET_NAME" \
  --value "$SPN_JSON" \
  --output none

# backend config (terraform)
cat > .azure.conf <<EOF
resource_group_name = "$RESOURCE_GROUP_NAME"
storage_account_name = "$STORAGE_ACCOUNT_NAME"
container_name = "$CONTAINER_NAME"
key = "terraform.tfstate"
subscription_id = "$SUBSCRIPTION_ID"
EOF

# bash script
cat > .azure.env <<EOF
export RESOURCE_GROUP_NAME="$RESOURCE_GROUP_NAME"
export STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT_NAME"
export CONTAINER_NAME="$CONTAINER_NAME"
export KEY_VAULT_NAME="$KEY_VAULT_NAME"
export SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export SP_NAME="$SP_NAME"
EOF

echo "Finish"