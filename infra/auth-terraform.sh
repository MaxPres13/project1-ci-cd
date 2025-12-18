#!/bin/bash

echo "🔄 Logging into Azure..."
az login

echo "🔧 Setting environment variables for AzureRM v4.x authentication..."

export ARM_USE_AZUREAD=true
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)

echo "🌍 Terraform will now use your Azure CLI authentication."
echo "Subscription: $ARM_SUBSCRIPTION_ID"
echo "Tenant:        $ARM_TENANT_ID"

echo "🚀 Initializing Terraform..."
terraform init

echo "📋 Running Terraform plan..."
terraform plan
