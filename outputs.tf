output "lambda_function_arn" {
  description = "The ARN of the created Lambda function."
  value       = aws_lambda_function.my_lambda_function.arn
}