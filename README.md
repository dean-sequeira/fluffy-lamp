# Fluffy Lamp

This project is an example of creating a "Hello, World!" AWS Lambda function using Terraform. The Lambda function is written in Python and can be deployed using Terraform. Additionally, there is an option to use a Docker container for local testing.

## Project Structure

- `main.tf`: Terraform configuration file to create the IAM role and Lambda function.
- `lambda_function.py`: Python code for the Lambda function.
- `Dockerfile`: Dockerfile to create a container for local testing of the Lambda function.
- `requirements.txt`: Python dependencies for the Lambda function.
- `README.md`: Project documentation.

## Prerequisites

- Terraform
- AWS CLI
- Docker
- Python
- pip

## Setup

### Terraform Deployment

1. **Initialize Terraform:**
    ```sh
    terraform init
    ```

2. **Apply Terraform Configuration:**
    ```sh
    terraform apply
    ```

### Local Testing with Docker

1. **Build Docker Image:**
    ```sh
    docker build -t hello-world-lambda .
    ```

2. **Run Docker Container:**
    ```sh
    docker run -p 9000:8080 hello-world-lambda
    ```

3. **Invoke Lambda Function Locally:**
    ```sh
    curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
    ```

## Lambda Function

The Lambda function is a simple "Hello, World!" function defined in `lambda_function.py`:

```python
def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello, World!'
    }
```
## Terraform Configuration
The Terraform configuration in main.tf includes:  
- An IAM policy document allowing Lambda to assume the role.
- An IAM role for the Lambda function.
- Packaging the Python Lambda function code into a zip file.
- Defining the Lambda function resource.

## Docker Configuration
The Dockerfile sets up a container for local testing:
```Dockerfile
FROM public.ecr.aws/lambda/python:3.11

COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip install -r requirements.txt
COPY lambda_function.py ${LAMBDA_TASK_ROOT}
CMD [ "lambda_function.handler" ]
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```