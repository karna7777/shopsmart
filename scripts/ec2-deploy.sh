#!/usr/bin/env sh
set -eu

APP_DIR="${APP_DIR:-$HOME/shopsmart}"
REPO_URL="${REPO_URL:?Set REPO_URL to your GitHub repository HTTPS URL}"
IMAGE_NAME="${IMAGE_NAME:-shopsmart-backend}"
CONTAINER_NAME="${CONTAINER_NAME:-shopsmart-backend}"
APP_PORT="${APP_PORT:-5001}"

if command -v sudo >/dev/null 2>&1 && command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl git docker.io

  sudo systemctl enable docker
  sudo systemctl start docker
fi

DOCKER="docker"
if command -v sudo >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

if [ ! -d "$APP_DIR/.git" ]; then
  git clone "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"
git fetch origin main
git checkout main
git pull --ff-only origin main

$DOCKER build -t "$IMAGE_NAME:latest" -f server/Dockerfile server

if $DOCKER ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  $DOCKER rm -f "$CONTAINER_NAME"
fi

$DOCKER run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "$APP_PORT:5001" \
  "$IMAGE_NAME:latest"

$DOCKER ps --filter "name=$CONTAINER_NAME"
