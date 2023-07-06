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
          "Service": "apigateway.amazonaws.com"
        },
        "Action": "lambda:InvokeFunction"
      },
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