resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_efs_policy_attachment" {
  name       = "lambda-efs-access-attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.efs_access_policy.arn
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/liferay_deploy.py"
  output_path = "${path.module}/../build/liferay_deploy.zip"
}


resource "aws_lambda_function" "my_lambda" {
  function_name = "LiferayDeploy"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "liferay_deploy.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.module}/../build/liferay_deploy.zip"

  file_system_config {
    arn              = aws_efs_access_point.lambda_ap.arn
    local_mount_path = "/mnt/${var.liferay_deploy_dir}"
  }

  vpc_config {
    subnet_ids         = aws_subnet.ecs_subnet[*].id
    security_group_ids = [aws_security_group.liferay_sg.id]
  }

  depends_on = [aws_efs_access_point.lambda_ap, aws_cloudwatch_log_group.lambda_log_group ]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/LiferayDeploy" # The name of the log group should match your Lambda function's expected log group
  retention_in_days = 3 # Optional: Set the log retention policy (in days)
}



resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_trigger_bucket.arn
}
