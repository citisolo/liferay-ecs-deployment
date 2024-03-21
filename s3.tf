resource "aws_s3_bucket" "lambda_trigger_bucket" {
  bucket = "open-liferay-deploy-lambda-trigger-bucket"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    # filter_suffix       = ".txt"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}