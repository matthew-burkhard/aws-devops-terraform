terraform {

  backend "remote" {
    # name of the Terraform Cloud organization
    organization = "burkhard-technologies"

    # name of the Terraform Cloud workspace to store TF state files in
    workspaces {
      name = "aws-devops-terraform"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app_server" {
  ami           = "ami-03f38e546e3dc59e1"
  instance_type = "t2.micro"
  count         = 0

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my-api"
  description = "My API"
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "my-resource"
}

resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.my_resource.id
  http_method             = aws_api_gateway_method.my_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda_function.invoke_arn
}


resource "aws_api_gateway_deployment" "my_deployment" {
  depends_on = [aws_api_gateway_integration.my_integration]

  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"
}

resource "aws_route53_record" "my_dns_record" {
  zone_id = "Z3OYTZKKMKB833"
  name    = "burkhard-technologies.com"
  type    = "A"

  alias {
    name                   = aws_api_gateway_deployment.my_deployment.invoke_url
    zone_id                = aws_api_gateway_deployment.my_deployment.execution_arn
    evaluate_target_health = false
  }
}

resource "aws_lambda_function" "my_lambda_function" {
  filename      = "my-lambda-function.zip"
  function_name = "my-lambda-function"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "main"
  runtime       = "go1.x"
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      MY_VARIABLE = "my-value"
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}