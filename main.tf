provider "aws" {
  region = "us-east-1"
}

# S3 Bucket for Static Website
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = "ggdevops-portfolio"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.portfolio_bucket.bucket
  key    = "index.html"
  source = "index.html"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "styles" {
  bucket = aws_s3_bucket.portfolio_bucket.bucket
  key    = "styles.css"
  source = "styles.css"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "scripts" {
  bucket = aws_s3_bucket.portfolio_bucket.bucket
  key    = "scripts.js"
  content = templatefile("scripts_template.js", {
    api_id = aws_api_gateway_rest_api.visitor_api.id
    region = var.region
  })
  acl    = "public-read"
}

variable "region" {
  default = "us-east-1"
}

# DynamoDB Table for Visitor Counter
resource "aws_dynamodb_table" "visitor_count" {
  name         = "VisitorCount"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda Function
resource "aws_lambda_function" "visitor_counter_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "VisitorCounterFunction"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_count.name
    }
  }

  source_code_hash = filebase64sha256("lambda_function.zip")
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "visitor_api" {
  name        = "VisitorCounterAPI"
  description = "API to count visitors"
}

resource "aws_api_gateway_resource" "visitor_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "visitor"
}

resource "aws_api_gateway_method" "visitor_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.visitor_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "visitor_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_api.id
  resource_id             = aws_api_gateway_resource.visitor_resource.id
  http_method             = aws_api_gateway_method.visitor_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_counter_lambda.invoke_arn
}

# CloudFront Distribution for S3 Bucket
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.portfolio_bucket.bucket_regional_domain_name
    origin_id   = "S3-Website"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["ggdevops.net"]  # Your custom domain

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-Website"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "api_gateway_endpoint" {
  value = aws_api_gateway_rest_api.visitor_api.execution_arn
}
