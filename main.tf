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
  region = "us-east-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-03f38e546e3dc59e1"
  instance_type = "t2.micro"
  count = 0
  
  tags = {
    Name = "ExampleAppServerInstance"
  }
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}