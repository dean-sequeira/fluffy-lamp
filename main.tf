# Define the IAM policy document that allows Lambda to assume the role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Create an IAM role for the Lambda function using the policy document
resource "aws_iam_role" "iam_for_lambda" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Package the Python Lambda function code into a zip file
data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.lambda_source_file
  output_path = var.lambda_output_path
}

# Define the Lambda function resource
resource "aws_lambda_function" "test_lambda" {
  # Specify the zip file containing the Lambda function code
  filename = var.lambda_output_path
  # Name of the Lambda function
  function_name = var.lambda_function_name
  # ARN of the IAM role for the Lambda function
  role = aws_iam_role.iam_for_lambda.arn
  # Handler for the Lambda function
  handler = var.lambda_handler
  # Source code hash to detect changes
  source_code_hash = data.archive_file.lambda.output_base64sha256
  # Runtime environment for the Lambda function
  runtime = var.lambda_runtime
}

# Create the API Gateway REST API using the api_ + lambda_function_name
resource "aws_api_gateway_rest_api" "api" {
  name        = var.lambda_function_name
  description = "API to trigger Lambda"
}

# Create a resource under the API path /<lambda_function_name>
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.lambda_function_name
}

# Create a method for the resource
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate the method with the Lambda function
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}

# Deploy the API
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

# Grant API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
