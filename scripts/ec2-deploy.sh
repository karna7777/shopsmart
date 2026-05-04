#!/usr/bin/env sh
set -eu

APP_DIR="${APP_DIR:-$HOME/shopsmart}"
REPO_URL="${REPO_URL:?Set REPO_URL to your GitHub repository HTTPS URL}"

if [ ! -d "$APP_DIR/.git" ]; then
  git clone "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"
git fetch origin main
git checkout main
git pull --ff-only origin main

cd server
npm ci --omit=dev

if command -v pm2 >/dev/null 2>&1; then
  pm2 restart shopsmart-backend || pm2 start src/index.js --name shopsmart-backend
  pm2 save
else
  npm start
fi
