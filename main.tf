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
