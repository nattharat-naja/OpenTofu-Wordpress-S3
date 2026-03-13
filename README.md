# 🚀 WordPress on AWS with OpenTofu

This project deploys a highly available WordPress infrastructure on AWS using OpenTofu (Terraform fork). The setup includes a VPC with public and private subnets across multiple availability zones, an EC2 instance running WordPress, a Multi-AZ MariaDB RDS instance, and an S3 bucket for media storage.

## 🏗️ Architecture

- 🌐 **VPC**: Custom VPC with public and private subnets across two availability zones
- 💻 **EC2 Instance**: Ubuntu-based instance running Apache, PHP, and WordPress in a public subnet
- 🗄️ **RDS MariaDB**: Multi-AZ database instance in private subnets for high availability
- 📦 **S3 Bucket**: Storage for WordPress media files with IAM role-based access
- 🔒 **Security Groups**: Configured for web traffic (HTTP/HTTPS/SSH) and database access
- 📍 **Elastic IP**: Static public IP address for the WordPress instance

## ✅ Prerequisites

- OpenTofu installed ([installation guide](https://opentofu.org/docs/intro/install/))
- AWS CLI configured with appropriate credentials
- An AWS account with permissions to create VPC, EC2, RDS, S3, and IAM resources
- An EC2 key pair named "IAC" in your AWS region

## 🔐 AWS Authentication Setup

OpenTofu needs AWS credentials to manage your infrastructure. Choose one of these methods:

### Method 1: AWS CLI Configuration (Recommended)

1. Install AWS CLI if not already installed:
   - Windows: Download from [AWS CLI installer](https://aws.amazon.com/cli/)
   - Or use: `winget install Amazon.AWSCLI`

2. Configure your credentials:
```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-west-1`)
- Default output format (e.g., `json`)

### Method 2: Environment Variables

Set these environment variables in your terminal:

**Windows (CMD):**
```cmd
set AWS_ACCESS_KEY_ID=your-access-key
set AWS_SECRET_ACCESS_KEY=your-secret-key
set AWS_DEFAULT_REGION=us-west-1
```

**Windows (PowerShell):**
```powershell
$env:AWS_ACCESS_KEY_ID="your-access-key"
$env:AWS_SECRET_ACCESS_KEY="your-secret-key"
$env:AWS_DEFAULT_REGION="us-west-1"
```

### Method 3: Shared Credentials File

Create or edit `~/.aws/credentials`:
```ini
[default]
aws_access_key_id = your-access-key
aws_secret_access_key = your-secret-key
```

And `~/.aws/config`:
```ini
[default]
region = us-west-1
```

### Verify Connection

Test your AWS connection:
```bash
aws sts get-caller-identity
```

You should see your AWS account details if configured correctly.

## 📁 Project Structure

```
.
├── main.tf                 # Root module orchestrating all components
├── provider.tf             # AWS provider configuration
├── variables.tf            # Root variable declarations
├── outputs.tf              # Root outputs
├── terraform.tfvars        # Variable values (customize this)
├── app/                    # EC2 instance module
├── bucket/                 # S3 bucket and IAM role module
├── db/                     # RDS MariaDB module
├── security_group/         # Security groups module
└── vpc/                    # VPC and networking module
```

## ⚙️ Configuration

1. Update `terraform.tfvars` with your values:

```hcl
region              = "us-west-1"
availability_zone_a = "us-west-1a"
availability_zone_b = "us-west-1b"
ami                 = "ami-0290e60ec230db1e4"  # Ubuntu AMI for your region
bucket_name         = "your-unique-bucket-name"
database_name       = "wordpress"
database_user       = "your-db-username"
database_pass       = "your-secure-password"
```

2. Ensure you have an EC2 key pair named "IAC" in your AWS region, or modify the key name in `app/main.tf`.

## 🚢 Deployment

1. Initialize OpenTofu:
```bash
tofu init
```

2. Review the execution plan:
```bash
tofu plan
```

3. Apply the configuration:
```bash
tofu apply
```

4. Confirm by typing `yes` when prompted.

## 🌍 Accessing WordPress

After deployment completes, get the public IP address:

```bash
tofu output app_public_ip
```

Access WordPress at: `http://<public-ip>`

Complete the WordPress installation wizard using the database credentials from your `terraform.tfvars`.

## ✨ Features

- **Multi-AZ Database**: Automatic failover for high availability
- **S3 Integration**: WordPress media files stored in S3 using the WP Offload Media plugin
- **Security**: Database in private subnets, security groups restricting access
- **Block Public Access**: S3 bucket configured with public access blocks and bucket owner enforced ownership
- **IAM Roles**: EC2 instance uses IAM role with AmazonS3FullAccess for S3 operations

## 🧹 Cleanup

To destroy all resources:

```bash
tofu destroy
```

Confirm by typing `yes` when prompted.

## 📝 Notes

- The RDS instance has `skip_final_snapshot = true` for easier cleanup during development
- For production, set `skip_final_snapshot = false` and configure backup retention
- The S3 bucket uses a prefix `uploads/` for WordPress media files
- Database requires secure transport is disabled for compatibility (set to 0)

## 🔧 Troubleshooting

- If deployment fails, check AWS service quotas and IAM permissions
- Ensure the AMI ID is valid for your selected region
- Verify the EC2 key pair exists before deployment
- Check security group rules if unable to access WordPress
