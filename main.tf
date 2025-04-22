provider "aws" {
  region = "us-east-1"
}

# 1. EC2 Instances
resource "aws_instance" "server1" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  tags = {
    default = "Server-1"
  }
}

resource "aws_instance" "server2" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  tags = {
    default = "Server-2"
  }
}

# 2. IAM Role for Lambda
resource "aws_iam_role" "lambda_execution" {
  name = "LambdaEC2ControlRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 3. IAM Policy for Lambda
resource "aws_iam_role_policy" "ec2_control_policy" {
  name = "EC2ControlPolicy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

# 4. Lambda Functions
resource "aws_lambda_function" "start_server1" {
  filename         = "lambda_start_server1.zip"
  function_name    = "LambdaStartServer1"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda_start_server1.zip")
}

resource "aws_lambda_function" "start_server2" {
  filename         = "lambda_start_server2.zip"
  function_name    = "LambdaStartServer2"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda_start_server2.zip")
}

# 5. CloudWatch Event Rules
resource "aws_cloudwatch_event_rule" "rule1" {
  name = "EC2StopTrigger1"
  event_pattern = jsonencode({
    source = ["aws.ec2"],
    "detail-type" = ["EC2 Instance State-change Notification"],
    detail = {
      state = ["stopped"]
    }
  })
}

resource "aws_cloudwatch_event_rule" "rule2" {
  name = "EC2StopTrigger2"
  event_pattern = jsonencode({
    source = ["aws.ec2"],
    "detail-type" = ["EC2 Instance State-change Notification"],
    detail = {
      state = ["stopped"]
    }
  })
}

resource "aws_cloudwatch_event_target" "target1" {
  rule      = aws_cloudwatch_event_rule.rule1.name
  target_id = "StartServer1"
  arn       = aws_lambda_function.start_server1.arn
}

resource "aws_cloudwatch_event_target" "target2" {
  rule      = aws_cloudwatch_event_rule.rule2.name
  target_id = "StartServer2"
  arn       = aws_lambda_function.start_server2.arn
}

# 6. Permissions for Lambda to be invoked by CloudWatch
resource "aws_lambda_permission" "allow_cloudwatch1" {
  statement_id  = "AllowExecutionFromCloudWatch1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_server1.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule1.arn
}

resource "aws_lambda_permission" "allow_cloudwatch2" {
  statement_id  = "AllowExecutionFromCloudWatch2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_server2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule2.arn
}

# 7. Outputs
output "server1_id" {
  value       = aws_instance.server1.id
  description = "ID of Server 1"
}

output "server2_id" {
  value       = aws_instance.server2.id
  description = "ID of Server 2"
}
