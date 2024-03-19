#!/bin/bash

# Check for AWS CLI
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found. Please install it before proceeding."
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install it before proceeding."
    exit 1
fi

# Check for input arguments
if [ $# -eq 0 ]
then
    echo "No username specified. Usage: $0 <username>"
    exit 1
fi

# User input
USERNAME=$1

# Variables
POLICY_NAME="ECSDeploymentPolicy"
POLICY_DOCUMENT="file://ecs_policy.json"

# Create IAM user
echo "Creating IAM user: $USERNAME..."
aws iam create-user --user-name $USERNAME

# Create the policy document
echo "Creating policy document..."
cat > ecs_policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:Describe*",
        "ecs:List*",
        "ecs:RegisterTaskDefinition",
        "ecs:DeregisterTaskDefinition",
        "ecs:UpdateService",
        "ecs:CreateService",
        "ecs:DeleteService",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create and attach the policy to the user
echo "Creating and attaching policy..."
POLICY_ARN=$(aws iam create-policy --policy-name $POLICY_NAME --policy-document $POLICY_DOCUMENT --query 'Policy.Arn' --output text)
aws iam attach-user-policy --user-name $USERNAME --policy-arn $POLICY_ARN

# Create access key for the user and capture the output
echo "Creating access key..."
ACCESS_KEYS=$(aws iam create-access-key --user-name $USERNAME)

# Output the access keys
echo "Access key and Secret access key for user $USERNAME:"
echo $ACCESS_KEYS | jq '.AccessKey | {AccessKeyId: .AccessKeyId, SecretAccessKey: .SecretAccessKey}'

# Reminder to store the credentials securely
echo "Store these credentials securely. They will not be shown again."
