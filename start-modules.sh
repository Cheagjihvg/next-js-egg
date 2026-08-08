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
# BUILD ENGINE CHECK (CONDITIONAL) - FIXED: case-insensitive, trims whitespace
# =========================
SHOULD_BUILD=$(echo "${BUILD_NEXT:-true}" | tr '[:upper:]' '[:lower:]' | xargs)
echo "[Modules] BUILD_NEXT raw='${BUILD_NEXT}' normalized='${SHOULD_BUILD}'"
if [ "${NODE_RUN_ENV}" = "start" ]; then
  if [[ "$SHOULD_BUILD" =~ ^(false|0|no|off|n)$ ]]; then
    echo "[Modules] BUILD_NEXT resolved to false. Skipping compilation step to protect existing build folder assets."
  else
    echo "[Modules] Building Next.js application..."
    $PM run build
  fi
else
  echo "[Modules] NODE_RUN_ENV != start, skipping build step (dev mode)."
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
# CLOUDFLARED MODULE (FIXED: logs to file, arch-aware, explicit failure reasons)
# =========================
if [ "${CLOUDFLARED_STATUS}" = "1" ]; then
  echo "[Modules] Starting Cloudflared..."

  if [ -z "${CLOUDFLARED_TOKEN}" ]; then
    echo "[Modules][cloudflared] ERROR: CLOUDFLARED_STATUS=1 but CLOUDFLARED_TOKEN is empty. Tunnel not started."
  else
    CF_BINARY=""
    if [ -f "/home/container/cloudflared" ]; then
      CF_BINARY="/home/container/cloudflared"
    elif [ -f "/home/container/modules/cloudflared/cloudflared" ]; then
      CF_BINARY="/home/container/modules/cloudflared/cloudflared"
    fi

    # Verify the binary actually exists and matches this container's architecture;
    # re-download for the correct arch if missing or broken (this is the most common
    # silent-failure cause: amd64 binary on an arm64 host = instant exec error, no log).
    ARCH=$(uname -m)
    case "$ARCH" in
      x86_64) CF_ARCH="amd64" ;;
      aarch64|arm64) CF_ARCH="arm64" ;;
      armv7l) CF_ARCH="arm" ;;
      *) CF_ARCH="amd64" ;;
    esac

    NEED_DOWNLOAD=0
    if [ -z "$CF_BINARY" ]; then
      NEED_DOWNLOAD=1
    else
      chmod +x "$CF_BINARY"
      if ! "$CF_BINARY" --version >/home/container/cloudflared_versioncheck.log 2>&1; then
        echo "[Modules][cloudflared] Existing binary failed to execute (likely wrong architecture: host is ${ARCH}). Re-downloading for ${CF_ARCH}..."
        NEED_DOWNLOAD=1
      fi
    fi

    if [ "$NEED_DOWNLOAD" = "1" ]; then
      curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}" -o /home/container/cloudflared \
        && chmod +x /home/container/cloudflared \
        && CF_BINARY="/home/container/cloudflared" \
        || echo "[Modules][cloudflared] ERROR: download failed, no internet or GitHub blocked from this container."
    fi

    if [ -n "$CF_BINARY" ] && [ -x "$CF_BINARY" ]; then
      echo "[Modules][cloudflared] Launching tunnel, logging to /home/container/cloudflared.log"
      "$CF_BINARY" tunnel --no-autoupdate run --token "${CLOUDFLARED_TOKEN}" > /home/container/cloudflared.log 2>&1 &
      CF_PID=$!
      sleep 2
      if ! kill -0 "$CF_PID" 2>/dev/null; then
        echo "[Modules][cloudflared] ERROR: tunnel process died immediately. Check /home/container/cloudflared.log — usually means an invalid or expired CLOUDFLARED_TOKEN."
      fi
    else
      echo "[Modules][cloudflared] ERROR: no working cloudflared binary available, tunnel not started."
    fi
  fi
fi

# =========================
# START NEXT
# =========================
echo "[Modules] Starting Next.js..."
exec npx next ${NODE_RUN_ENV} -H 0.0.0.0 -p ${SERVER_PORT}
