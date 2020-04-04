data "archive_file" "placeholder" {
  type        = "zip"
  source_file = "${path.module}/files/placeholder.py"
  output_path = "${path.module}/files/placeholder.zip"
}

resource "aws_iam_role" "r" {
  name               = "${var.env_prefix}-f-exec-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "a" {
  role       = aws_iam_role.r.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "f" {
  filename      = data.archive_file.placeholder.output_path
  function_name = "${var.env_prefix}-hello-world"
  role          = aws_iam_role.r.arn
  handler       = "placeholder.handler"
  runtime       = "python3.7"
  publish       = true

  lifecycle {
    ignore_changes = [
      version,
      environment,
      runtime,
      timeout,
      memory_size,
      source_code_hash
    ]
  }
}

resource "aws_lambda_alias" "f" {
  name             = "production"
  description      = "alias intended for use"
  function_name    = aws_lambda_function.f.arn
  function_version = aws_lambda_function.f.version

  lifecycle {
    ignore_changes = [
      function_version
    ]
  }
}

resource "aws_cloudwatch_log_group" "f" {
  name = "/aws/lambda/${aws_lambda_function.f.function_name}"
}