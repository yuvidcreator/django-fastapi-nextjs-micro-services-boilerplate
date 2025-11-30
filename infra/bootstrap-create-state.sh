#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Bootstrap Script for Terraform Remote State (AWS mode) or VPS local mode
# -------------------------------------------------------------------------
# Modes:
#   DEPLOY_TARGET=vps → No remote state, local .terraform directory works.
#   DEPLOY_TARGET=aws → Creates S3 bucket + optional DynamoDB lock table.
#
# Reads: .env or passed vars.
###############################################################################

YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

echo -e "${BLUE}=== SOCIALX: BOOTSTRAP REMOTE STATE ===${RESET}"

###############################################################################
# Load .env if exists
###############################################################################
if [[ -f ".env" ]]; then
    echo -e "${YELLOW}Loading .env...${RESET}"
    export $(grep -v '^#' .env | xargs -d '\n')
fi

###############################################################################
# Validate DEPLOY_TARGET
###############################################################################
if [[ -z "${DEPLOY_TARGET:-}" ]]; then
    echo -e "${RED}[ERROR] DEPLOY_TARGET not defined in environment or .env${RESET}"
    exit 1
fi

echo -e "${BLUE}Deployment Mode Detected:${RESET} ${GREEN}$DEPLOY_TARGET${RESET}"

###############################################################################
# VPS MODE — Nothing to create
###############################################################################
if [[ "$DEPLOY_TARGET" == "vps" ]]; then
    echo -e "${GREEN}[VPS MODE] No remote state required.${RESET}"
    echo -e "${BLUE}Terraform will store state locally under ./infra/.terraform${RESET}"
    echo -e "${GREEN}Bootstrap complete (VPS mode).${RESET}"
    exit 0
fi

###############################################################################
# AWS MODE — Create S3 bucket + DynamoDB lock table
###############################################################################
if [[ "$DEPLOY_TARGET" != "aws" ]]; then
    echo -e "${RED}[ERROR] Unknown DEPLOY_TARGET: $DEPLOY_TARGET${RESET}"
    exit 1
fi

###############################################################################
# Validate AWS variables
###############################################################################
if [[ -z "${TFSTATE_BUCKET:-}" || -z "${AWS_REGION:-}" ]]; then
    echo -e "${RED}[ERROR] TFSTATE_BUCKET and/or AWS_REGION missing in .env${RESET}"
    exit 1
fi

echo -e "${BLUE}AWS Mode: Using bucket:${RESET} ${GREEN}$TFSTATE_BUCKET${RESET}"
echo -e "${BLUE}AWS Region:${RESET} ${GREEN}$AWS_REGION${RESET}"

###############################################################################
# Create S3 Bucket if not exists
###############################################################################
echo -e "${YELLOW}Checking S3 bucket existence...${RESET}"

if aws s3api head-bucket --bucket "$TFSTATE_BUCKET" 2>/dev/null; then
    echo -e "${GREEN}[OK] Bucket already exists: $TFSTATE_BUCKET${RESET}"
else
    echo -e "${YELLOW}Creating S3 bucket...${RESET}"
    if [[ "$AWS_REGION" == "us-east-1" ]]; then
        aws s3api create-bucket \
            --bucket "$TFSTATE_BUCKET"
    else
        aws s3api create-bucket \
            --bucket "$TFSTATE_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi
    echo -e "${GREEN}[DONE] Bucket created.${RESET}"
fi

###############################################################################
# Enable versioning & encryption
###############################################################################
echo -e "${YELLOW}Configuring versioning & encryption...${RESET}"

aws s3api put-bucket-versioning \
    --bucket "$TFSTATE_BUCKET" \
    --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
    --bucket "$TFSTATE_BUCKET" \
    --server-side-encryption-configuration '{
        "Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]
    }'

echo -e "${GREEN}[DONE] Versioning and encryption configured.${RESET}"

###############################################################################
# Create DynamoDB Lock Table
###############################################################################
DDB_TABLE="${TFSTATE_DYNAMODB_TABLE:-terraform-locks}"

echo -e "${BLUE}Using DynamoDB Lock Table:${RESET} ${GREEN}$DDB_TABLE${RESET}"

if aws dynamodb describe-table --table-name "$DDB_TABLE" --region "$AWS_REGION" >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] DynamoDB lock table exists.${RESET}"
else
    echo -e "${YELLOW}Creating DynamoDB lock table...${RESET}"

    aws dynamodb create-table \
        --table-name "$DDB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION"

    echo -e "${GREEN}[DONE] DynamoDB lock table created.${RESET}"
fi

###############################################################################
# SUMMARY & NEXT STEPS
###############################################################################
echo -e "${BLUE}========================================${RESET}"
echo -e "${GREEN}REMOTE STATE BOOTSTRAP COMPLETE${RESET}"
echo -e "${BLUE}========================================${RESET}"

echo -e "${YELLOW}Next Steps:${RESET}"

echo -e "1) Configure backend.tf in infra/:"
echo -e "   ${GREEN}bucket       = \"$TFSTATE_BUCKET\"${RESET}"
echo -e "   ${GREEN}region       = \"$AWS_REGION\"${RESET}"
echo -e "   ${GREEN}dynamodb_table = \"$DDB_TABLE\"${RESET}"

echo ""
echo -e "2) Run:"
echo -e "   ${GREEN}cd infra && terraform init${RESET}"

echo ""
echo -e "3) Apply staging infrastructure:"
echo -e "   ${GREEN}terraform apply -var-file=staging.tfvars${RESET}"

echo ""
echo -e "4) After EKS is created:"
echo -e "   ${GREEN}aws eks update-kubeconfig --name <cluster> --region $AWS_REGION${RESET}"

echo ""
echo -e "5) Deploy ArgoCD + services via GitOps afterwards."
echo ""
