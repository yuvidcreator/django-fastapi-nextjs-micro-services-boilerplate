#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# SOCIALX — VPS DEPLOYMENT SCRIPT
# -----------------------------------------------------------------------------
# Requirements:
#   - .env or env/vps.env containing VPS_HOST, VPS_SSH_USER, VPS_SSH_KEY_PATH
#   - docker-compose.vps.yml on the VPS under /opt/socialx/
#   - images already pushed to local registry or pulled from CI
#
# Usage:
#   scripts/deploy-vps.sh
#
###############################################################################

YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

echo -e "${BLUE}=== SOCIALX: VPS DEPLOYMENT ===${RESET}"

###############################################################################
# Load environment variables
###############################################################################
if [[ -f ".env" ]]; then
    echo -e "${YELLOW}Loading .env ...${RESET}"
    export $(grep -v '^#' .env | xargs -d '\n')
fi

if [[ "$DEPLOY_TARGET" != "vps" ]]; then
    echo -e "${RED}[ERROR] DEPLOY_TARGET is '${DEPLOY_TARGET}', expected 'vps'${RESET}"
    exit 1
fi

if [[ ! -f "env/vps.env" ]]; then
    echo -e "${RED}[ERROR] env/vps.env not found${RESET}"
    exit 1
fi

###############################################################################
# Validate required variables
###############################################################################
required_vars=(VPS_HOST VPS_SSH_USER VPS_SSH_KEY_PATH DOCKER_REGISTRY_HOST DEFAULT_IMAGE_TAG)
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo -e "${RED}[ERROR] Missing env variable: $var${RESET}"
        exit 1
    fi
done

echo -e "${GREEN}Using VPS host:${RESET} $VPS_HOST"
echo -e "${GREEN}Using registry:${RESET} $DOCKER_REGISTRY_HOST"

###############################################################################
# SSH connectivity test
###############################################################################
echo -e "${YELLOW}Testing SSH connectivity...${RESET}"

if ssh -i "$VPS_SSH_KEY_PATH" -o StrictHostKeyChecking=no "${VPS_SSH_USER}@${VPS_HOST}" "echo ok" 2>/dev/null; then
    echo -e "${GREEN}[OK] SSH connection successful.${RESET}"
else
    echo -e "${RED}[ERROR] SSH connection FAILED.${RESET}"
    exit 1
fi

###############################################################################
# Upload environment file to VPS
###############################################################################
echo -e "${YELLOW}Uploading env/vps.env to VPS...${RESET}"

scp -i "$VPS_SSH_KEY_PATH" -o StrictHostKeyChecking=no \
    env/vps.env \
    "${VPS_SSH_USER}@${VPS_HOST}:/opt/socialx/env.vps.env"

echo -e "${GREEN}[DONE] Environment file uploaded.${RESET}"

###############################################################################
# Remote deployment commands
###############################################################################
REMOTE_COMMANDS=$(cat << 'EOF'
set -e

echo ">> Pulling latest container images..."
docker compose --env-file /opt/socialx/env.vps.env -f /opt/socialx/docker-compose.vps.yml pull

echo ">> Updating services..."
docker compose --env-file /opt/socialx/env.vps.env -f /opt/socialx/docker-compose.vps.yml up -d

echo ">> Cleaning up unused images..."
docker image prune -af >/dev/null 2>&1 || true

echo ">> Checking service health..."
sleep 5

if curl -s http://localhost:8001/health | grep -q "ok"; then
    echo "User-service is healthy."
else
    echo "User-service health FAILED."
    exit 1
fi

if curl -s http://localhost:8002/health | grep -q "ok"; then
    echo "Feed-service is healthy."
else
    echo "Feed-service health FAILED."
    exit 1
fi

if curl -s http://localhost:3000 | grep -q "<html"; then
    echo "Frontend is responding."
else
    echo "Frontend health FAILED."
    exit 1
fi

echo ">> Deployment successful."
EOF
)

###############################################################################
# Execute remote commands via SSH
###############################################################################
echo -e "${BLUE}Deploying to VPS now...${RESET}"

ssh -i "$VPS_SSH_KEY_PATH" -o StrictHostKeyChecking=no \
    "${VPS_SSH_USER}@${VPS_HOST}" \
    "bash -s" <<< "$REMOTE_COMMANDS"

echo -e "${GREEN}=== DEPLOYMENT COMPLETE ===${RESET}"
