# Desafio Mercado Livre

## Descrição do Projeto
O desafio deste projeto está dividido em 4 etapas principais, com o objetivo de construir uma arquitetura de API robusta, escalável, resiliente, segura e interativa com IA.

## RUN.MD
Para saber como executar este projeto veja em [RUN.MD](/run.md)

### 1. Ambiente de API Seguro e Resiliente
A primeira etapa focou na construção de uma API segura e resiliente usando **AWS API Gateway REST**.  
Essa escolha garante um ambiente de API gerenciado que lida com o tráfego, autorização e integrações de forma eficiente.

### 2. Infraestrutura de Aplicação com Kubernetes
Para rodar a aplicação, foi escolhido o Kubernetes, especificamente o **Amazon EKS (Elastic Kubernetes Service)**.  
Com o EKS, não há a necessidade de se preocupar com a gestão de master nodes ou bancos de dados do cluster, permitindo focar na aplicação.  
Além disso, o EKS se integra de forma nativa com outros serviços da AWS.

### 3. Aplicação Node.js
A aplicação em si foi desenvolvida em **Node.js**.  
A sua função é ler um arquivo em formato `.json` que atua como um banco de dados simples.  
O seu conteúdo é exposto através de um endpoint privado que se comunica diretamente com o API Gateway.

---

## Visão Geral da Arquitetura do API Gateway
- Provisiona um **API Gateway REST** como ponto de entrada público para a API.  
- Define o recurso `/products` com método **GET**, exigindo uma **API Key** para autenticação.  
- Integração segura com um **NLB privado** via **VPC Link**.  
- Mapeamento para o domínio personalizado `api.coreplatform.com.br`.  
- Gerenciado por **API Keys** e **Planos de Uso**.  
- Respostas de erro **4xx** e **5xx** customizadas para melhor experiência do cliente.

---

## Visão Geral da Arquitetura do EKS
O módulo Terraform provisiona um cluster **EKS** e seus componentes essenciais:

- Criação de uma **VPC** completa.  
- **Grupo de nós gerenciado** com AMI Bottlerocket.  
- Instalação de add-ons via **eks-blueprints-addons**:
  - AWS Load Balancer Controller  
  - Metrics Server  
- Integração com **ECR** para imagens Docker.  
- Configuração de **OIDC** e **IAM Role** para GitHub Actions.  
- Deploy facilitado com **ArgoCD** e **NGINX Ingress Controller** via Helm.  

---

## Visão Geral da Aplicação Node.js
Microsserviço em **Node.js** com arquitetura em **Express.js**, incluindo:

- Middlewares para **CORS** e **tratamento de erros**.  
- Instrumentação com **OpenTelemetry** (métricas e tracing).  
- Desenvolvimento com **Docker Compose**.  
- Dockerfile otimizado para produção (imagem leve para EKS).

---

## Detalhamento dos Recursos Terraform

### 1. Conexão e API Base
- `data "aws_lb" "my_nlb"` → busca NLB existente.  
- `resource "aws_api_gateway_rest_api" "example"` → cria API REST principal.  

### 2. Recurso e Método da API
- `aws_api_gateway_resource.test` → define `/products`.  
- `aws_api_gateway_method.get_test` → cria método **GET**.  

### 3. Integração com NLB Privado (VPC Link)
- `aws_api_gateway_vpc_link.nlb_link` → cria conexão privada.  
- `aws_api_gateway_integration.nlb_integration` → conecta GET ao NLB.  

### 4. Respostas e Deployment
- `aws_api_gateway_method_response.ok`  
- `aws_api_gateway_integration_response.ok`  
- `aws_api_gateway_deployment.example` com `triggers = { redeployment = timestamp() }`  
- `aws_api_gateway_stage.dev`  

### 5. API Keys e Plano de Uso
- `aws_api_gateway_api_key.example`  
- `aws_api_gateway_usage_plan.example`  
- `aws_api_gateway_usage_plan_key.example`  

### 6. Domínio Personalizado e DNS
- `aws_api_gateway_domain_name.custom`  
- `aws_api_gateway_base_path_mapping.custom`  
- `aws_route53_record.api`  

### 7. Respostas de Erro Personalizadas

#### Erros de Cliente (4xx)
- **ACCESS_DENIED (403)**: Token inválido (Cognito).  
  - `"Acesso negado: Por favor, forneça um token válido ou chame o suporte"`  
- **INVALID_API_KEY (403)**: API Key inválida.  
  - `"Acesso negado: Forneça uma chave API-KEY válida"`  
- **EXPIRED_TOKEN (403)**: API Key expirada.  
  - `"Solicite uma nova chave API-KEY. A atual está vencida"`  

#### Erros de Servidor (5xx)
- **AUTHORIZER_FAILURE (500)**: Falha no autorizador (Lambda Authorizer).  
  - `"Erro 500: Problema ou instabilidade no servidor"`  
- **INTEGRATION_FAILURE (504)**: Timeout na integração com NLB.  
  - `"Erro 504: Problema ou instabilidade nas integrações"`  

---

## 8. Infraestrutura Kubernetes (EKS)
- `module "vpc"` → cria VPC dedicada.  
- `module "eks"` → cria cluster EKS.  
- `module "eks_blueprints_addons"` → instala add-ons essenciais.  
- `aws_ecr_repository.desafio_meli_app` → repositório no ECR.  
- `aws_ecr_lifecycle_policy.desafio_meli_app` → política de ciclo de vida de imagens.  
- `helm_release.ingress_nginx` & `helm_release.argocd` → Ingress e ArgoCD via Helm.  
- `module "ebs_csi_driver_irsa"` → provisiona roles IAM para o cluster.  
- `null_resource.push_image` → build & push da imagem para o ECR.  

---

## 9. Aplicação Node.js

### Estrutura de Arquivos
- `package.json` → dependências (Express, OpenTelemetry, Jest, ESLint).  
- `Dockerfile` → imagem baseada em Node.js 18 Alpine.  
- `docker-compose.yml` → ambiente local simplificado.  
- `src/index.mjs` → ponto de entrada (Express + middlewares).  
- `src/instrumentation.mjs` → inicializa OpenTelemetry.  
- `src/products.json` → banco de dados estático.  
- `src/middleware/cors.mjs` → middleware de CORS.  
- `src/middleware/customErrors.mjs` → tratamento de erros.  
- `src/routes/api.mjs` → rotas da API (`GET /api/products` e `GET /api/products/:id`).  

---
## Futuro

- `Escalabilidade da APP/PODS` → Utilizar EFS para o arquivo `.json` que está servindo de "Banco de dados", com o AWS EFS poderei compartilhar o arquivo com varios POD's.
- `Deploy CICD via GIT com GitOps` → Usando OIDC entre AWS e Github, helm e argocd.
- `Autenticação JWT na API` → Neste conexto usaria o AWS Cognito no papel de OAuth 2.0.
- `Camada de borda` → Adicionaria a Cloudflare como CDN e WAF do meu ambiente.
- `Teste end-to-end` → Usando o Cypress por exemplo, será possível valida o fluxo completo da aplicação, do começo ao fim, para garantir que o sistema funciona para o usuário final.
- `Testes unitarios` → Para garantir o funcionamento isolado de cada parte do código.

# Tecnologias que temos em nossa Stalck:

| Name                              | Bool              | Who                  | description                                                                          |
|-----------------------------------|-------------------|----------------------|--------------------------------------------------------------------------------------|
| `Eks Escalavel`                   | ✓                 | Karpenter            | Baseado em consumo de cpu, memo, requests                                           |
| `Observabilidade`                 | ✓                 | Dynatrace            | Deploy utiizando helm-chart                                                         |
| `API     `                        | ✓                 | Aws Api Gtw          | Api REST criada com IaaS                                                            |
| `Container Registry`              | ✓                 | Aws Ecr              | Gerencia e armazena imagens                                                         |
| `Instrumentação de Aplicação`     | ✓                 | Opentelemetry        | SDK para Node Js                                                                    |
| `Tratamento de Erros da API`      | ✓                 | Gateway Response     | Feature do Aws Api                                                                  |
| `Prevenção de Throttle`           | ✓                 | Burst and Rate limit | Feature do Aws Api                                                                  |
| `IA Agents`                       | ✓                 | n8n                  | Consumindo nossa API e sugerindo evolução dos produtos listados                     |
| `Projeto compativel com PCI 4.0`  | ✓                 | Aws Bottlerocket     | Sistema operacional baseado em Linux construído sob medida para executar contêineres| 