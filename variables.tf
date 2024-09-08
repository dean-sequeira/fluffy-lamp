
variable "iam_role_name" {
  description = "The name of the IAM role for the Lambda function"
  type        = string
  default     = "iam_for_lambda"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "my_test_lambda"
}

variable "lambda_source_file" {
  description = "The path to the Python Lambda function code"
  type        = string
  default     = "lambda_function.py"
}

variable "lambda_output_path" {
  description = "The path to the output zip file for the Lambda function code"
  type        = string
  default     = "lambda_function_payload.zip"
}

variable "lambda_handler" {
  description = "The handler for the Lambda function"
  type        = string
  default     = "lambda_function.handler"
}

variable "lambda_runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
  default     = "python3.11"
}
