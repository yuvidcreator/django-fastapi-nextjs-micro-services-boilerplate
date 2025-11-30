# infra/backend.tf
terraform {
    required_version = ">= 1.5.0"
    backend "s3" {
        bucket         = var.tfstate_bucket
        key            = "${var.app_name}/${terraform.workspace}.tfstate"
        region         = var.aws_region
        encrypt        = true
        # dynamodb_table = var.tfstate_dynamodb_table   # optional: enable if using DynamoDB locks
        # use_lockfile = true  # for newer Terraform versions: S3-native locking (toggle as needed)
    }
}
