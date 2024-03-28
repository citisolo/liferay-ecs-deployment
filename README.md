# LifeRay DXP Dev Container Image Deployment Guide

This guide provides the steps to deploy your application using Terraform. Follow these steps to set up your architecture and access your application via the web.

## Prerequisites

Before you begin, ensure you have the following prerequisites installed and configured:

- Terraform
- AWS CLI
- Access to an AWS account with necessary permissions

## Deployment Steps

1. **Initialise Terraform**

   Open a terminal in the root directory of your project and run the following command to initialize Terraform:

   ```bash
   cd infra
   terraform init

2. **Review the Terraform Plan and Apply**
   Generate an execution plan for Terraform. This step allows you to see what resources Terraform will create, modify, or destroy.
   Carefully review the output to ensure that it matches your expectations and does not contain any unexpected actions.

   ```bash
   terraform plan
   terraform apply

3. **Access  Application**
   After Terraform successfully applies the configuration, it will output the DNS address of the Application Load Balancer (ALB) that routes traffic to your application. Look for an output named something like alb_dns_name:
   
   ```bash
   Outputs:

   alb_dns_name = "your-alb-dns-name.eu-west-1.elb.amazonaws.com"

4. **Shutdown**
   After usage the app can be shutdown via Terraform (all data will be destroyed.)

   ```bash
   terraform destroy