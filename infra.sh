#!/bin/bash
set -euo pipefail

#======================
# Variáveis
#======================
LOCATION="brazilsouth"
RANDOM_ID=$RANDOM

RESOURCE_GROUP="rg-techchallenge-fiap-postech"
STORAGE_ACCOUNT="sapostech$RANDOM_ID"

CREATED=$(date +%Y-%m-%d)
OWNER="Webber Chagas"
TAGS="created=$CREATED owner=$OWNER"

#=======================================================
# Workspace log (Obrigatório para application insights)
#=======================================================
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name ws-applogs-fiap-postech
echo "Workspace criado com sucesso."
echo ""

#=======================================================
# Criar o Application Insights no Workspace
#=======================================================
az monitor app-insights component create \
  --app ai-logs-app-fiap-postech\
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --workspace ws-applogs-fiap-postech
echo "Application Insights criado com sucesso."
echo ""

#=============================================
# Storage Account (obrigatório para Functions)
#=============================================
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --tags $TAGS
echo "Storage account: $STORAGE_ACCOUNT, criado com sucesso."
echo ""

#======================
# Functions
#======================
  FUNC_GATEWAY="func-api-gateway-$RANDOM"
  echo "Criando Function App: $FUNC_GATEWAY."
  az functionapp create \
    --name $FUNC_GATEWAY \
    --resource-group $RESOURCE_GROUP \
    --storage-account $STORAGE_ACCOUNT \
    --app-insights ai-logs-app-fiap-postech \
    --flexconsumption-location $LOCATION \
    --runtime java \
    --runtime-version 21 \
    --tags $TAGS
  echo "Function app: $FUNC_GATEWAY, criado com sucesso."
  echo ""

  FUNC_COURSE="func-course-rating-$RANDOM"
  echo "Criando Function App: $FUNC_COURSE, responsável por acessar registrar avalição"
  az functionapp create \
    --name $FUNC_COURSE \
    --resource-group $RESOURCE_GROUP \
    --storage-account $STORAGE_ACCOUNT \
    --app-insights ai-logs-app-fiap-postech \
    --flexconsumption-location $LOCATION \
    --runtime java \
    --runtime-version 21 \
    --tags $TAGS
  echo "Function app: $FUNC_COURSE, criado com sucesso."
  echo ""
  
  FUNC_NOTIFICATION="func-ms-notification-$RANDOM"
  echo "Criando Function App: $FUNC_NOTIFICATION, responsável por notificar avaliações criticas "
  az functionapp create \
    --name $FUNC_NOTIFICATION \
    --resource-group $RESOURCE_GROUP \
    --storage-account $STORAGE_ACCOUNT \
    --app-insights ai-logs-app-fiap-postech \
    --flexconsumption-location $LOCATION \
    --runtime java \
    --runtime-version 17 \
    --tags $TAGS
  echo "Function app: $FUNC_NOTIFICATION, criado com sucesso."
  echo ""

  FUNC_REPORT="func-weekly-report-$RANDOM"
  echo "Criando Function App: $FUNC_REPORT, responsável pelo relatório semanal de avaliações"
  az functionapp create \
    --name $FUNC_REPORT \
    --resource-group $RESOURCE_GROUP \
    --storage-account $STORAGE_ACCOUNT \
    --app-insights ai-logs-app-fiap-postech \
    --flexconsumption-location $LOCATION \
    --runtime java \
    --runtime-version 21 \
    --tags $TAGS
  echo "Function app: $FUNC_REPORT, criado com sucesso."
  echo ""

#========================
# Criação do Service Bus  
#========================
az servicebus namespace create \
  --resource-group $RESOURCE_GROUP \
  --name sb-post-tech-fiap \
  --location $LOCATION \
  --sku Basic

  echo "Function app: $FUNC_REPORT, criado com sucesso."
  echo ""

#=================================
# Criação das Filas no Service Bus 
#=================================
az servicebus queue create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name sb-post-tech-fiap \
  --name q-ms-critical-ratings \
  --max-size 1024

az servicebus queue create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name sb-post-tech-fiap \
  --name q-ms-weekly-report \
  --max-size 1024

#===================================================
# Criação das politicas de Consumer e producer no Service Bus
#===================================================
az servicebus namespace authorization-rule create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name sb-post-tech-fiap \
  --name sb-producer-policy \
  --rights Send
az servicebus namespace authorization-rule create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name sb-post-tech-fiap \
  --name sb-consumer-policy \
  --rights Listen


#==========================================================================
# Obtem o connection string para acesso ao recurso Producer no Service Bus
#==========================================================================
az servicebus namespace authorization-rule keys list \
  --resource-group $RESOURCE_GROUP \
  --namespace-name sb-post-tech-fiap \
  --name sb-producer-policy

#==========================================================================
# Obtem o connection string para acesso ao recurso Consumer no Service Bus
#==========================================================================
az servicebus namespace authorization-rule keys list \
  --resource-group $RESOURCE_GROUP \
  --namespace-name sb-post-tech-fiap \
  --name sb-consumer-policy
