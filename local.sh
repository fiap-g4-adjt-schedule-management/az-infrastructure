set -euo pipefail

## =====================
## Variaveis
## =====================
RESOURCE_GROUP="nome-do-resource-group"
LOCATION="brazilsouth"

CREATED_AT=$(date +%Y-%m-%d)
USER="nome-do-executor"
TAGS="created=$CREATED_AT owner=$USER"

ROLE_NAME_INFRA="nome-do-app-registration-para-infra"
ROLE_NAME_WEBAPP="nome-do-app-registration-para-webapp"

## ===========================================
## Repositório do github para criação do OIDC
## ===========================================
ORG="seu-nome-OU-nome-da-org"
REPO_INFRA="repositorio-infra-com-os-scripts"
REPO_WEBAPP="repositorio-da-api-gateway"

## ==================================================
## Definindo qual assinatura e tenant vai utilizar
## ==================================================
SUB_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

## ==================================
## Login utilizando usuário e senha
## ==================================
echo "🔐 Realizando login no Azure..."
az login
echo "Login efetuado com sucesso."

az account set az account set --subscription $SUB_ID

# =======================
# Criação do RESOURCE GROUP
# =======================
echo "Criando Resource group!"
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags $TAGS
echo "Resource Group, foi criado com sucesso: $RESOURCE_GROUP "
echo ""

#================================
# CRIAÇÃO COMPLETA DA ROLE INFRA
#================================
echo "Criando App Registration da Infra"
APP_ID_INFRA=$(az ad app create --display-name "$ROLE_NAME_INFRA" --query appId -o tsv)
echo "App Registration da infra, foi criado com sucesso!"
echo ""

echo "Criando Service Principal da Infra"
SP_ID_INFRA=$(az ad sp create --id "$APP_ID_INFRA" --query id -o tsv)
echo "Service Principal da infra, foi criado com sucesso!"
echo ""

az role assignment create \
  --assignee-object-id "$SP_ID_INFRA" \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RESOURCE_GROUP"
echo "Role Contributor, foi atribuido ao SP da infra!"

az ad app federated-credential create \
  --id $APP_ID_INFRA \
  --parameters "{
    "name": "infra-oidc",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:$ORG/$REPO_INFRA:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }"
echo "OIDC de infra, foi criado para o SP!" 
echo ""

#=================================
# CRIAÇÃO COMPLETA DA ROLE WebApp
#=================================
echo "Criando App Registration do WebApp"
APP_ID_WEBAPP=$(az ad app create --display-name "$ROLE_NAME_WEBAPP" --query appId -o tsv)
echo "App Registration do WebApp, foi criado com sucesso!"
echo ""

echo "Criando Service Principal do WebApp"
SP_ID_WEBAPP=$(az ad sp create --id "$APP_ID_WEBAPP" --query id -o tsv)
echo "Service Principal do WebApp, foi criado com sucesso!"
echo ""

az role assignment create \
  --assignee-object-id "$SP_ID_WEBAPP" \
  --assignee-principal-type ServicePrincipal \
  --role "Website Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RESOURCE_GROUP"
echo "Role WebSite Contributor, foi atribuido ao SP do WebApp!"
echo ""

az ad app federated-credential create \
  --id $APP_ID_WEBAPP \
  --parameters "{
    "name": "webapp-oidc",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:$ORG/$REPO_WEBAPP:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }"
echo "OIDC do WebApp, foi criado para o SP!"
echo ""

echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUB_ID"
echo ""
echo "AZURE_INFRA_ID=$APP_ID_INFRA"
echo ""
echo "AZURE_WEBAPP_ID=$APP_ID_WEBAPP"
echo ""
