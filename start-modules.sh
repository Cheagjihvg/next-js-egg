#!/bin/bash

cd /home/container

echo "[Modules] Booting Next.js system..."

# =========================
# GITHUB AUTO CLONE
# =========================
if [ ! -f package.json ]; then
  if [ -n "${GIT_URL}" ]; then
    echo "[Modules] Cloning GitHub repo..."

    if [[ ${GIT_URL} != *.git ]]; then
      GIT_URL=${GIT_URL%/}.git
    fi

    if [ -n "${USERNAME}" ] && [ -n "${ACCESS_TOKEN}" ]; then
      GIT_URL="https://${USERNAME}:${ACCESS_TOKEN}@$(echo ${GIT_URL} | cut -d/ -f3-)"
    fi

    git clone "${GIT_URL}" . || true
  fi
fi

# =========================
# CREATE NEXT PROJECT IF EMPTY
# =========================
if [ ! -f package.json ]; then
  echo "[Modules] Creating Next.js project..."
  npm init -y
  npm pkg set type="module"
  npm pkg set scripts.dev="next dev"
  npm pkg set scripts.build="next build"
  npm pkg set scripts.start="next start"
  npm install next@${NEXT_VERSION:-latest} react react-dom
fi

# =========================
# AUTO UPDATE
# =========================
if [ -d .git ] && [ "${AUTO_UPDATE}" = "1" ]; then
  echo "[Modules] Pulling updates..."
  git pull
fi

# =========================
# PACKAGE MANAGER DETECT
# =========================
corepack enable >/dev/null 2>&1 || true

PM=${PACKAGE_MANAGER:-auto}

if [ "$PM" = "auto" ]; then
  if [ -f pnpm-lock.yaml ]; then PM=pnpm;
  elif [ -f yarn.lock ]; then PM=yarn;
  else PM=npm;
  fi
fi

echo "[Modules] Using: $PM"

if [ "$PM" = "pnpm" ]; then
  pnpm install
elif [ "$PM" = "yarn" ]; then
  yarn install
else
  npm install
fi

# =========================
# BUILD (ONLY START MODE)
# =========================
if [ "${NODE_RUN_ENV}" = "start" ]; then
  echo "[Modules] Building..."
  $PM run build
fi

# =========================
# CRON MODULE
# =========================
if [ "${CRON_STATUS}" = "1" ]; then
  echo "[Modules] Starting Cron..."
  service cron start >/dev/null 2>&1 || true
  cron -f &
fi

# =========================
# CLOUDFLARED MODULE
# =========================
if [ "${CLOUDFLARED_STATUS}" = "1" ]; then
  echo "[Modules] Starting Cloudflared..."
  cloudflared tunnel --no-autoupdate run --token ${CLOUDFLARED_TOKEN} &
fi

# =========================
# START NEXT
# =========================
echo "[Modules] Starting Next.js..."
npx next ${NODE_RUN_ENV} -H 0.0.0.0 -p ${SERVER_PORT}

wait
