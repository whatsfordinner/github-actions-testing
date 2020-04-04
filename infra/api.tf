resource "aws_api_gateway_rest_api" "gw" {
  name        = "${var.env_prefix}-hello-api"
  description = "Hello World API for ${var.env_prefix}"

  endpoint_configuration {
    types = [
      "REGIONAL"
    ]
  }
}

resource "aws_api_gateway_resource" "r" {
  rest_api_id = aws_api_gateway_rest_api.gw.id
  parent_id   = aws_api_gateway_rest_api.gw.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "m" {
  rest_api_id   = aws_api_gateway_rest_api.gw.id
  resource_id   = aws_api_gateway_resource.r.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "f" {
  rest_api_id             = aws_api_gateway_rest_api.gw.id
  resource_id             = aws_api_gateway_resource.r.id
  http_method             = aws_api_gateway_method.m.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.f.invoke_arn
}

resource "aws_lambda_permission" "f" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.f.function_name
  qualifier     = aws_lambda_alias.f.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gw.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "d" {
  depends_on  = [aws_api_gateway_integration.f]
  rest_api_id = aws_api_gateway_rest_api.gw.id
}

resource "aws_api_gateway_stage" "v1" {
  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.gw.id
  deployment_id = aws_api_gateway_deployment.d.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.gw.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

resource "aws_cloudwatch_log_group" "gw" {
  name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.gw.id}/v1"
}