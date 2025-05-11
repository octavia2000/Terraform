# Secure Static Website on AWS

This project deploys a secure static website using AWS S3 and CloudFront. It demonstrates how to create a static website with proper security configurations using Infrastructure as Code (Terraform).

## Architecture Overview

The architecture includes:
- **S3 Bucket**: Stores the static website files
- **CloudFront Distribution**: Content delivery network for global access
- **Origin Access Identity**: Restricts direct access to the S3 bucket

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- An AWS account with necessary permissions

## Quick Start

1. Clone this repository
2. Update the S3 bucket name in `main.tf` to ensure uniqueness
3. Initialize and apply the terraform configuration:

```bash
terraform init
terraform apply
```

4. Access your website using the CloudFront URL displayed in the outputs

## Features

- **Secure S3 Setup**: All public access to the S3 bucket is blocked
- **CloudFront Integration**: Content is delivered securely via HTTPS
- **Infrastructure as Code**: Entire infrastructure defined and versioned in code
- **Custom Error Pages**: Configured error handling for better user experience

## Security

- ✅ Public access to S3 bucket is blocked
- ✅ Access to content only through CloudFront
- ✅ HTTPS enforced with redirect from HTTP
- ✅ Proper IAM permissions with least privilege

## Customization

To customize the website:
1. Modify the HTML content in the `local_file` resources
2. For more complex websites, update the resource configuration to include additional files
3. Adjust CloudFront caching behavior as needed for your content

## Outputs

- **CloudFront URL**: The URL to access your website

## Clean Up

To tear down the infrastructure:

```bash
terraform destroy
```