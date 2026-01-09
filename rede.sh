#==============================
# Variáveis
#=================================
source .env

: "${RESOURCE_GROUP:?}"
: "${VNET_NAME:?}"
: "${SUBNET_FUNCTIONS:?}"
: "${SUBNET_PRIVATE_ENDPOINT:?}"
: "${LOCATION:?}"

#=================================
# Criar a VNet e Subnets
#=================================
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --location $LOCATION

#=======================================
# Subnet para integração das Functions
#========================================
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_FUNCTIONS \
  --address-prefix 10.0.1.0/24 \
  --delegations Microsoft.Web/serverFarms

#=================================
# Subnet para Private Endpoints
#=================================
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_PRIVATE_ENDPOINT \
  --address-prefix 10.0.2.0/24 \
  --disable-private-endpoint-network-policies true

#=================================
# Criar as Private DNS Zones
#=================================
az network private-dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name privatelink.servicebus.windows.net

# Azure Functions OK
az network private-dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name privatelink.azurewebsites.net

#=================================
# Linkar DNS à VNet OK
#=================================
az network private-dns link vnet create \
  --resource-group $RESOURCE_GROUP \
  --zone-name privatelink.servicebus.windows.net \
  --name link-sb \
  --virtual-network $VNET_NAME \
  --registration-enabled false
  
az network private-dns link vnet create \
  --resource-group $RESOURCE_GROUP \
  --zone-name privatelink.azurewebsites.net \
  --name link-functions \
  --virtual-network $VNET_NAME \
  --registration-enabled false

#=======================================
# Integrar Functions privadas à VNet
#=======================================
az functionapp vnet-integration add \
  --resource-group $RESOURCE_GROUP \
  --name $FUNC_GATEWAY \
  --vnet $VNET_NAME \
  --subnet $SUBNET_FUNCTIONS

az functionapp vnet-integration add \
  --resource-group $RESOURCE_GROUP \
  --name $FUNC_COURSE \
  --vnet $VNET_NAME \
  --subnet $SUBNET_FUNCTIONS

az functionapp vnet-integration add \
  --resource-group $RESOURCE_GROUP \
  --name $FUNC_NOTIFICATION \
  --vnet $VNET_NAME \
  --subnet $SUBNET_FUNCTIONS
  
az functionapp vnet-integration add \
  --resource-group $RESOURCE_GROUP \
  --name $FUNC_REPORT \
  --vnet $VNET_NAME \
  --subnet $SUBNET_FUNCTIONS

#================================================
# Criar Private Endpoint das Functions privadas 
#===============================================
az network private-endpoint create \
  --name pe-func-$FUNC_COURSE \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_PRIVATE_ENDPOINT \
  --private-connection-resource-id $(az functionapp show \
      --name $FUNC_COURSE \
      --resource-group $RESOURCE_GROUP \
      --query id -o tsv) \
  --group-id sites \
  --connection-name pe-func-$FUNC_COURSE-conn
  
az network private-endpoint create \
  --name pe-func-$FUNC_NOTIFICATION \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_PRIVATE_ENDPOINT \
  --private-connection-resource-id $(az functionapp show \
      --name $FUNC_NOTIFICATION \
      --resource-group $RESOURCE_GROUP \
      --query id -o tsv) \
  --group-id sites \
  --connection-name pe-func-$FUNC_NOTIFICATION-conn
  
az network private-endpoint create \
  --name pe-func-$FUNC_REPORT \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_PRIVATE_ENDPOINT \
  --private-connection-resource-id $(az functionapp show \
      --name $FUNC_REPORT \
      --resource-group $RESOURCE_GROUP \
      --query id -o tsv) \
  --group-id sites \
  --connection-name pe-func-$FUNC_REPORT-conn

# Associar DNS: OK
az network private-endpoint dns-zone-group create \
  --resource-group $RESOURCE_GROUP \
  --endpoint-name pe-func-$FUNC_COURSE \
  --name func-b-dns \
  --private-dns-zone privatelink.azurewebsites.net \
  --zone-name privatelink.azurewebsites.net
  
az network private-endpoint dns-zone-group create \
  --resource-group $RESOURCE_GROUP \
  --endpoint-name pe-func-$FUNC_NOTIFICATION \
  --name func-c-dns \
  --private-dns-zone privatelink.azurewebsites.net \
  --zone-name privatelink.azurewebsites.net
  
az network private-endpoint dns-zone-group create \
  --resource-group $RESOURCE_GROUP \
  --endpoint-name pe-func-$FUNC_REPORT \
  --name func-d-dns \
  --private-dns-zone privatelink.azurewebsites.net \
  --zone-name privatelink.azurewebsites.net

#=================================
# Bloquear acesso público das Functions privadas
#=================================
az functionapp config access-restriction add \
  --resource-group $RESOURCE_GROUP \
  --name $FUNC_COURSE \
  --rule-name "PermitirVNet" \
  --action Allow \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_FUNCTIONS \
  --priority 100
  
az functionapp config access-restriction add \
  --resource-group $RESOURCE_GROUP \
  --name $FUNC_NOTIFICATION \
  --rule-name "PermitirVNet" \
  --action Allow \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_FUNCTIONS \
  --priority 100
  
az functionapp config access-restriction add \
  --resource-group $RESOURCE_GROUP \
  --name $FUNC_REPORT \
  --rule-name "PermitirVNet" \
  --action Allow \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_FUNCTIONS \
  --priority 100