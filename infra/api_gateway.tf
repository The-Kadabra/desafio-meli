# -------------------------------
# Data source para o NLB existente
# -------------------------------
data "aws_lb" "my_nlb" {
  name = "k8s-ingressn-ingressn-67daa5e470"
}

# -------------------------------
# Criando o API Gateway REST
# -------------------------------
resource "aws_api_gateway_rest_api" "example" {
  name        = "desafio-rest-api"
  description = "API Gateway com VPC Link para NLB privado"
}

# -------------------------------
# Resource /products
# -------------------------------
resource "aws_api_gateway_resource" "test" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "products"
}

# -------------------------------
# Método GET (exige API Key)
# -------------------------------
resource "aws_api_gateway_method" "get_test" {
  rest_api_id      = aws_api_gateway_rest_api.example.id
  resource_id      = aws_api_gateway_resource.test.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

# -------------------------------
# Criando o VPC Link para o NLB
# -------------------------------
resource "aws_api_gateway_vpc_link" "nlb_link" {
  name        = "desafio-vpc-link"
  target_arns = [data.aws_lb.my_nlb.arn]
}

# -------------------------------
# Integração do método GET com o NLB via VPC Link
# -------------------------------
resource "aws_api_gateway_integration" "nlb_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.test.id
  http_method             = aws_api_gateway_method.get_test.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "https://internal-api.coreplatform.com.br/api/products"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.nlb_link.id
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.header.Host" = "'internal-api.coreplatform.com.br'"
  }
}

#########################
# Responses (customizadas)
#########################

# 200 OK
resource "aws_api_gateway_method_response" "ok" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.test.id
  http_method = aws_api_gateway_method.get_test.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "ok" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.test.id
  http_method = aws_api_gateway_method.get_test.http_method
  status_code = aws_api_gateway_method_response.ok.status_code
}

# -------------------------------
# Deployment + Stage
# -------------------------------
resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  deployment_id = aws_api_gateway_deployment.example.id
  stage_name    = "dev"
}

# -------------------------------
# API Key + Usage Plan
# -------------------------------
resource "aws_api_gateway_api_key" "example" {
  name    = "desafio-api-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "example" {
  name = "desafio-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.example.id
    stage  = aws_api_gateway_stage.dev.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "example" {
  key_id        = aws_api_gateway_api_key.example.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.example.id
}

# -------------------------------
# Custom Domain + DNS
# -------------------------------
resource "aws_api_gateway_domain_name" "custom" {
  domain_name              = "api.coreplatform.com.br"
  regional_certificate_arn = aws_acm_certificate.core_wildcard.arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "custom" {
  domain_name = aws_api_gateway_domain_name.custom.domain_name
  api_id      = aws_api_gateway_rest_api.example.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
}

data "aws_route53_zone" "main" {
  name         = "coreplatform.com.br"
  private_zone = false
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.coreplatform.com.br"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.custom.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom.regional_zone_id
    evaluate_target_health = false
  }
}