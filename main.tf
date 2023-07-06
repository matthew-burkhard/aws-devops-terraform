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

# resource "aws_route53_record" "my_dns_record" {
#   zone_id = "Z3OYTZKKMKB833"
#   name    = "burkhard-technologies.com"
#   type    = "A"

#   alias {
#     name                   = aws_api_gateway_deployment.my_deployment.invoke_url
#     zone_id                = aws_api_gateway_deployment.my_deployment.execution_arn
#     evaluate_target_health = false
#   }
# }

