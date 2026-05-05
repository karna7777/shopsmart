#!/usr/bin/env sh
set -eu

APP_DIR="${APP_DIR:-$HOME/shopsmart}"
REPO_URL="${REPO_URL:?Set REPO_URL to your GitHub repository HTTPS URL}"

if command -v sudo >/dev/null 2>&1 && command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl git

  if ! command -v node >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
    sudo -E bash /tmp/nodesource_setup.sh
    sudo apt-get install -y nodejs
  fi
fi

if ! command -v pm2 >/dev/null 2>&1; then
  sudo npm install -g pm2
fi

if [ ! -d "$APP_DIR/.git" ]; then
  git clone "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"
git fetch origin main
git checkout main
git pull --ff-only origin main

cd server
npm ci --omit=dev

pm2 restart shopsmart-backend || pm2 start src/index.js --name shopsmart-backend
pm2 save
