## ==================================================
## Comando para saber seu Tenant e subscript
## ==================================================
SUB_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

## ===========================================================================
## Login utilizando usuário e senha, comando para definir qual subscript usar
## ===========================================================================
az login
az account set az account set --subscription $SUB_ID

# ============================
# Criação do RESOURCE GROUP
# ============================
CREATED=$(date +%Y-%m-%d)
OWNER="Webber Chagas"
TAGS="created=$CREATED owner=$OWNER"
az group create \
  --name rg-techchallenge-fiap-postech \
  --location brazilsouth \
  --tags $TAGS
echo "Resource Group, foi criado com sucesso: $RESOURCE_GROUP "
echo ""

#================================
# CRIAÇÃO COMPLETA DA ROLE INFRA
#================================
echo "Criando App Registration da Infra"
APP_ID_INFRA=$(az ad app create --display-name "appr-infra-tc-fiap" --query appId -o tsv)
echo "App Registration da infra, foi criado com sucesso!"
echo ""

echo "Criando Service Principal da Infra"
SP_ID_INFRA=$(az ad sp create --id "sp-infra-tc-fiap" --query id -o tsv)
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
    "name": "infra-oidc-fiap-postech",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:fiap-g4-adjt-schedule-management/az-infrastructure:environment:dev",
    "audiences": ["api://AzureADTokenExchange"]
  }"
echo "OIDC de infra, foi criado para o SP!" 
echo ""

echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUB_ID"
echo "AZURE_INFRA_ID=$APP_ID_INFRA"
echo ""



#============================================================================
# Parte 2 - Executar após a finalização da infraestrutura;
#============================================================================

# API Gateway
echo "Criando App Registration da API Gateway"
APP_FUNC_GATEWAY=$(az ad app create --display-name "appr-func-api-gateway-fiap" --query appId -o tsv)
echo "App Registration da API Gateway, foi criado com sucesso!"
echo ""

echo "Criando Service Principal da API Gateway"
SP_FUNC_GATEWAY=$(az ad sp create --id "sp-func-api-gateway-fiap" --query id -o tsv)
echo "Service Principal da API Gateway, foi criado com sucesso!"
echo ""

az role assignment create \
  --assignee-object-id "$SP_FUNC_GATEWAY" \
  --assignee-principal-type ServicePrincipal \
  --role "Website Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$FUNCTION_GATEWAY_NAME"

az ad app federated-credential create \
  --id $APP_FUNC_GATEWAY \
  --parameters "{
    "name": "gateway-oidc-fiap-postech",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:fiap-g4-adjt-schedule-management/ms-api-gateway:environment:dev",
    "audiences": ["api://AzureADTokenExchange"]
  }"
echo "OIDC da API Gateway, foi criado para o SP!" 
echo ""
echo "AZURE_FUNC_GATEWAY=$APP_FUNC_GATEWAY"
echo ""

# Course Rating
echo "Criando App Registration da function Course Rating"
APP_FUNC_COURSE=$(az ad app create --display-name "appr-func-course-rating-fiap" --query appId -o tsv)
echo "App Registration da function Course Rating, foi criado com sucesso!"
echo ""

echo "Criando Service Principal da function Course Rating"
SP_FUNC_COURSE=$(az ad sp create --id "sp-func-course-rating-fiap" --query id -o tsv)
echo "Service Principal da function Course Rating, foi criado com sucesso!"
echo ""

az role assignment create \
  --assignee-object-id "$SP_FUNC_COURSE" \
  --assignee-principal-type ServicePrincipal \
  --role "Website Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$FUNCTION_COUSE_NAME"

az ad app federated-credential create \
  --id $APP_FUNC_COURSE \
  --parameters "{
    "name": "func-course-rating-oidc-fiap-postech",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:fiap-g4-adjt-schedule-management/course-rating-functions:environment:dev",
    "audiences": ["api://AzureADTokenExchange"]
  }"
echo "OIDC da function Course Rating, foi criado para o SP!" 
echo ""
echo "AZURE_FUNC_COURSE=$APP_FUNC_COURSE"
echo ""

# Notification Function
echo "Criando App Registration da Notification Function"
APP_FUNC_NOTIFICATION=$(az ad app create --display-name "appr-func-ms-notification-fiap" --query appId -o tsv)
echo "App Registration da Notification Function, foi criado com sucesso!"
echo ""

echo "Criando Service Principal da Notification Function"
SP_FUNC_NOTIFICATION=$(az ad sp create --id "sp-func-ms-notification-fiap" --query id -o tsv)
echo "Service Principal da Notification Function, foi criado com sucesso!"
echo ""

az role assignment create \
  --assignee-object-id "$SP_FUNC_NOTIFICATION" \
  --assignee-principal-type ServicePrincipal \
  --role "Website Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$FUNCTION_NOTIFICATION_NAME"

az ad app federated-credential create \
  --id $APP_FUNC_NOTIFICATION \
  --parameters "{
    "name": "func-ms-notification-oidc-fiap-postech",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:fiap-g4-adjt-schedule-management/ms-notificacao:environment:dev",
    "audiences": ["api://AzureADTokenExchange"]
  }"
echo "OIDC da Notification Function, foi criado para o SP!" 
echo ""
echo "AZURE_FUNC_NOTIFICATION=$APP_FUNC_NOTIFICATION"
echo ""

# Weekly Report
echo "Criando App Registration da function Weekly Report"
APP_FUNC_REPORT=$(az ad app create --display-name "appr-func-weekly-report-fiap" --query appId -o tsv)
echo "App Registration da function Weekly Report, foi criado com sucesso!"
echo ""

echo "Criando Service Principal da function Weekly Report"
SP_FUNC_REPORT=$(az ad sp create --id "sp-weekly-report-fiap" --query id -o tsv)
echo "Service Principal da function Weekly Report, foi criado com sucesso!"
echo ""

az role assignment create \
  --assignee-object-id "$SP_FUNC_REPORT" \
  --assignee-principal-type ServicePrincipal \
  --role "Website Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$FUNCTION_REPORT_NAME"

az ad app federated-credential create \
  --id $APP_FUNC_REPORT \
  --parameters "{
    "name": "func-weekly-report-oidc-fiap-postech",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:fiap-g4-adjt-schedule-management/ms-weekly-rating-report:environment:dev",
    "audiences": ["api://AzureADTokenExchange"]
  }"
echo "OIDC da function Weekly Report, foi criado para o SP!" 
echo ""
echo "AZURE_FUNC_GATEWAY=$APP_FUNC_REPORT"
echo ""