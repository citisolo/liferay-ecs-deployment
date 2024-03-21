#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found. Please install it."
    exit 1
fi

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <S3-Bucket-Name> <File-Path>"
    exit 1
fi

# Assign arguments to variables
BUCKET_NAME="$1"
FILE_PATH="$2"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "File does not exist: $FILE_PATH"
    exit 1
fi

# Extract filename from the file path
FILENAME=$(basename "$FILE_PATH")

# Upload the file to S3
aws s3 cp "$FILE_PATH" "s3://$BUCKET_NAME/$FILENAME"

if [ $? -eq 0 ]; then
    echo "File successfully uploaded to s3://$BUCKET_NAME/$FILENAME"
else
    echo "Failed to upload file."
    exit 1
fi
