#!/bin/bash
set -euo pipefail

AZURE_ENV=".azure.env"

if [ ! -f "$AZURE_ENV" ]; then
  echo "$AZURE_ENV no encontrado. Abortando."
  exit 1
fi

echo "Cargando variables desde $AZURE_ENV..."
set -a
source "$AZURE_ENV"
set +a

echo "Variables cargadas:"
echo "  RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME"
echo "  STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME"
echo "  CONTAINER_NAME=$CONTAINER_NAME"
echo "  KEY_VAULT_NAME=$KEY_VAULT_NAME"
echo "  SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
echo "  SP_NAME=$SP_NAME"

if [ -z "$SP_NAME" ]; then
  echo "sp_name está vacío. No se puede borrar el Service Principal."
else
  echo "Borrando Service Principal: $SP_NAME"
  az ad sp delete --id "$SP_NAME" || echo "Service Principal no encontrado o error al borrar."
fi

if [ -z "$KEY_VAULT_NAME" ]; then
  echo "key_vault_name está vacío. No se puede borrar el Key Vault."
else
  echo "Borrando Key Vault: $KEY_VAULT_NAME"
  az keyvault delete --name "$KEY_VAULT_NAME" --resource-group "$RESOURCE_GROUP_NAME" || echo "Key Vault no encontrado o error al borrar."
fi

if [ -z "$RESOURCE_GROUP_NAME" ]; then
  echo "resource_group_name está vacío. No se puede borrar el Resource Group."
else
  echo "Borrando Resource Group: $RESOURCE_GROUP_NAME"
  az group delete --name "$RESOURCE_GROUP_NAME" --yes --no-wait || echo "Resource Group no encontrado o error al borrar."
fi

echo "Infraestructura de bootstrap eliminada."
