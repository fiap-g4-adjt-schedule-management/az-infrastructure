# ☁️ Infraestrutura Azure 

Este diretório contém os scripts em Shell(.sh) utilizando Azure CLI, responsáveis por provisionar a **infraestrutura** do projeto **Tech Challenge – FIAP PósTech**.

A solução utiliza uma arquitetura orientada a eventos, com **Azure Functions** consumindo mensagens de filas do **Azure Service Bus**, garantindo escalabilidade, desacoplamento e segurança.

---

## 📁 Estrutura

```text
az-infrastructure/
├── infra.sh   # Criação dos recursos principais
└── rede.sh    # Configuração de rede e segurança
```

---

## 🌎 Região

* **Brazil South (brazilsouth)**

---

## 🧱 Recursos Criados

* **Resource Group**

  * `rg-techchallenge-fiap-postech`

* **Azure Functions (Java – Serverless)**

  * API Gateway
  * Registro de avaliações
  * Notificação de feedbacks críticos e envio de relatórios por email.
  * Relatório semanal
  * Runtime Java
  * Utilizam o Storage Account criado no script

* **Azure Service Bus**

  * Namespace: `sb-post-tech-fiap`
  * Filas:

    * `q-ms-critical-ratings`
    * `q-ms-weekly-report`
  * Políticas separadas para **Producer (Send)** e **Consumer (Listen)**

* **Azure Storage Account**

  * Necessário para funcionamento das Functions

* **Application Insights + Log Analytics**

  * Monitoramento, logs e métricas

---

## 🌐 Rede e Segurança

* **VNet**

  * Subnet para Azure Functions
  * Subnet para Private Endpoints

* **Private DNS Zones**

  * Linkar DNS à Vnet (Service Bus)
  * Azure Functions 

* **Private Endpoints**

  * Associa ao DNS
  * Integrar Functions privadas à VNet
  * Service Bus 

* **Acesso público bloqueado**

  * Functions acessíveis somente via VNet

---

## 🔁 Fluxo de Funcionamento

1. Serviços produtores enviam mensagens para o Service Bus
2. As mensagens ficam disponíveis nas filas
3. Azure Functions são acionadas automaticamente
4. Processamento e envio de notificações de feedbacks críticos e relatórios por email
5. Logs são enviados ao Application Insights

---

## ⚠️ Observações

* Scripts devem ser executados com Azure CLI configurado
* Requer permissão adequada na assinatura
* Os scripts utilizam bash (#!/bin/bash) e Azure CLI.

