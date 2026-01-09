#==============================
# Variáveis
#=================================
RESOURCE_GROUP="rg-techchallenge-fiap-postech"

#=================================
# Criar a VNet e Subnets OK
#=================================
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name vnet-functions-dev \
  --address-prefix 10.0.0.0/16 \
  --location brazilsouth

-Subnet para integração das Functions - OK
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-functions-dev \
  --name subnet-functions \
  --address-prefix 10.0.1.0/24 \
  --delegations Microsoft.Web/serverFarms

Subnet para Private Endpoints OK
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-functions-dev \
  --name subnet-private-endpoints \
  --address-prefix 10.0.2.0/24 \
  --disable-private-endpoint-network-policies true


2. Criar as Private DNS Zones OK
az network private-dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name privatelink.servicebus.windows.net

Azure Functions OK
az network private-dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name privatelink.azurewebsites.net

Linkar DNS à VNet OK
az network private-dns link vnet create \
  --resource-group $RESOURCE_GROUP \
  --zone-name privatelink.servicebus.windows.net \
  --name link-sb \
  --virtual-network vnet-functions-dev \
  --registration-enabled false
  
az network private-dns link vnet create \
  --resource-group $RESOURCE_GROUP \
  --zone-name privatelink.azurewebsites.net \
  --name link-functions \
  --virtual-network vnet-functions-dev \
  --registration-enabled false
  
  
3. Criar Private Endpoint do Service Bus SOMENTE PARA PREMIUM
az network private-endpoint create \
  --name pe-servicebus \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-functions-dev \
  --subnet subnet-private-endpoints \
  --private-connection-resource-id $(az servicebus namespace show \
      --name sb-dev-webber \
      --resource-group $RESOURCE_GROUP \
      --query id -o tsv) \
  --group-id namespace \
  --connection-name pe-sb-connection

Associar ao DNS:
az network private-endpoint dns-zone-group create \
  --resource-group $RESOURCE_GROUP \
  --endpoint-name pe-servicebus \
  --name sb-dns-group \
  --private-dns-zone privatelink.servicebus.windows.net \
  --zone-name privatelink.servicebus.windows.net


4. Integrar Functions privadas à VNet [3] OK
Para Função B, C e D: (repete para func-c e func-d)
az functionapp vnet-integration add \
  --resource-group $RESOURCE_GROUP \
  --name func-api-gateway-webber \
  --vnet vnet-functions-dev \
  --subnet subnet-functions

az functionapp vnet-integration add \
  --resource-group $RESOURCE_GROUP \
  --name func-course-rating-may \
  --vnet vnet-functions-dev \
  --subnet subnet-functions

az functionapp vnet-integration add \
  --resource-group $RESOURCE_GROUP \
  --name func-notification-raysse \
  --vnet vnet-functions-dev \
  --subnet subnet-functions
  
az functionapp vnet-integration add \
  --resource-group $RESOURCE_GROUP \
  --name func-weekly-report-Math \
  --vnet vnet-functions-dev \
  --subnet subnet-functions


5. Criar Private Endpoint das Functions privadas (repete para C e D)
az network private-endpoint create \
  --name pe-func-b \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-functions-dev \
  --subnet subnet-private-endpoints \
  --private-connection-resource-id $(az functionapp show \
      --name func-course-rating-may \
      --resource-group $RESOURCE_GROUP \
      --query id -o tsv) \
  --group-id sites \
  --connection-name pe-func-b-conn
  
az network private-endpoint create \
  --name pe-func-c \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-functions-dev \
  --subnet subnet-private-endpoints \
  --private-connection-resource-id $(az functionapp show \
      --name func-notification-raysse \
      --resource-group $RESOURCE_GROUP \
      --query id -o tsv) \
  --group-id sites \
  --connection-name pe-func-c-conn
  
az network private-endpoint create \
  --name pe-func-d \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-functions-dev \
  --subnet subnet-private-endpoints \
  --private-connection-resource-id $(az functionapp show \
      --name func-weekly-report-Math \
      --resource-group $RESOURCE_GROUP \
      --query id -o tsv) \
  --group-id sites \
  --connection-name pe-func-d-conn

Associar DNS: OK
az network private-endpoint dns-zone-group create \
  --resource-group $RESOURCE_GROUP \
  --endpoint-name pe-func-b \
  --name func-b-dns \
  --private-dns-zone privatelink.azurewebsites.net \
  --zone-name privatelink.azurewebsites.net
  
az network private-endpoint dns-zone-group create \
  --resource-group $RESOURCE_GROUP \
  --endpoint-name pe-func-c \
  --name func-c-dns \
  --private-dns-zone privatelink.azurewebsites.net \
  --zone-name privatelink.azurewebsites.net
  
az network private-endpoint dns-zone-group create \
  --resource-group $RESOURCE_GROUP \
  --endpoint-name pe-func-d \
  --name func-d-dns \
  --private-dns-zone privatelink.azurewebsites.net \
  --zone-name privatelink.azurewebsites.net

6. Bloquear acesso público das Functions privadas
az functionapp config access-restriction add \
  --resource-group $RESOURCE_GROUP \
  --name func-course-rating-may \
  --rule-name "PermitirVNet" \
  --action Allow \
  --vnet-name vnet-functions-dev \
  --subnet subnet-functions \
  --priority 100
  
az functionapp config access-restriction add \
  --resource-group $RESOURCE_GROUP \
  --name func-notification-raysse \
  --rule-name "PermitirVNet" \
  --action Allow \
  --vnet-name vnet-functions-dev \
  --subnet subnet-functions \
  --priority 100
  
az functionapp config access-restriction add \
  --resource-group $RESOURCE_GROUP \
  --name func-weekly-report-Math \
  --rule-name "PermitirVNet" \
  --action Allow \
  --vnet-name vnet-functions-dev \
  --subnet subnet-functions \
  --priority 100