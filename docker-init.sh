#!/bin/bash
# NetWatch Docker init script
# Downloads Ookla binary on first run if missing

SPEEDTEST="/app/bin/speedtest"

if [ ! -f "$SPEEDTEST" ]; then
  echo "[init] Downloading Ookla speedtest binary..."
  ARCH=$(uname -m)
  BASE="https://install.speedtest.net/app/cli"

  case "$ARCH" in
    aarch64) PKG="ookla-speedtest-1.2.0-linux-aarch64.tgz" ;;
    armv7l)  PKG="ookla-speedtest-1.2.0-linux-armhf.tgz" ;;
    *)       PKG="ookla-speedtest-1.2.0-linux-x86_64.tgz" ;;
  esac

  if wget -qO /tmp/speedtest.tgz "$BASE/$PKG" 2>/dev/null; then
    tar -xzf /tmp/speedtest.tgz -C /tmp
    mv /tmp/speedtest "$SPEEDTEST"
    chmod +x "$SPEEDTEST"
    rm -f /tmp/speedtest.tgz
    echo "[init] Ookla speedtest installed: $ARCH"
  else
    echo "[init] WARNING: Could not download Ookla binary - CF tests will still work"
  fi
else
  echo "[init] Ookla binary already present"
fi

echo "[init] Starting NetWatch..."
exec node /app/server.js
