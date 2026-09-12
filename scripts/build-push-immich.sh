#!/usr/bin/env bash
# One-time build + push of the Immich image to private ECR.
# Usage: REGION=ap-southeast-1 TAG=latest bash scripts/build-push-immich.sh
set -euo pipefail

REGION="${REGION:-ap-southeast-1}"
ACCOUNT_ID="018602188273"
REPO="devops-bootcamp/final-project-hanif-faez"
TAG="${TAG:-latest}"
URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/../app"

echo "Logging into ECR: ${URI}"
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$URI"

echo "Building immich image (t3.medium-tuned) from ${APP_DIR}"
docker build -t "${REPO}:${TAG}" "$APP_DIR"

echo "Tagging ${URI}:${TAG}"
docker tag "${REPO}:${TAG}" "${URI}:${TAG}"

echo "Pushing to ECR..."
docker push "${URI}:${TAG}"

echo "Done: ${URI}:${TAG}"