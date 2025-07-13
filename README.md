# Azure-De-Lijn

# Setup state storage account
```bash
az login
az group create --name rg-terraform-state --location westeurope
az storage account create --name sttfdelijnstate --resource-group rg-terraform-state --location westeurope --sku Standard_LRS
az storage container create --name tfstate --account-name sttfdelijnstate
```

# Create Service Principal for GitHub Actions
```bash
az ad sp create-for-rbac --name "sp-github-actions-delijn" --role "Contributor" --scopes "/subscriptions/[SUBSCRIPTION_ID]" --sdk-auth
```
