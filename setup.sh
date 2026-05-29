#!/usr/bin/env bash
# NetWatch - setup.sh
# Installs NetWatch as a systemd service on any Linux system
# Supports: Raspberry Pi OS, Ubuntu, TwisterOS, Umbrel, Debian
# Run as: bash setup.sh [port]
# Example: bash setup.sh 5218

set -e

NW_PORT="${1:-5218}"
NW_DIR="$(cd "$(dirname "$0")" && pwd)"
NW_USER="$(whoami)"
NW_HOME="$(eval echo ~$NW_USER)"
SERVICE_NAME="netwatch"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
TEMPLATE="${NW_DIR}/netwatch.service"

echo ""
echo "  NetWatch Setup"
echo "  =============="
echo "  User      : $NW_USER"
echo "  Directory : $NW_DIR"
echo "  Port      : $NW_PORT"
echo ""

# -- Check node is available
if ! command -v node &>/dev/null; then
  echo "  ERROR: node not found in PATH"
  echo "  Install Node.js: https://nodejs.org"
  echo "  On Pi: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
  exit 1
fi
NW_NODE="$(command -v node)"
echo "  Node      : $NW_NODE ($(node --version))"

# -- Check systemd
if ! command -v systemctl &>/dev/null; then
  echo "  ERROR: systemctl not found - systemd required"
  echo "  Alternative: run manually with: node $NW_DIR/server.js"
  exit 1
fi

# -- Check service template
if [ ! -f "$TEMPLATE" ]; then
  echo "  ERROR: netwatch.service template not found in $NW_DIR"
  exit 1
fi

# -- Check server.js
if [ ! -f "$NW_DIR/server.js" ]; then
  echo "  ERROR: server.js not found in $NW_DIR"
  exit 1
fi

# -- Generate service file from template
echo "  Generating service file..."
GENERATED=$(cat "$TEMPLATE" \
  | sed "s|%%NW_USER%%|$NW_USER|g" \
  | sed "s|%%NW_DIR%%|$NW_DIR|g" \
  | sed "s|%%NW_NODE%%|$NW_NODE|g" \
  | sed "s|%%NW_PORT%%|$NW_PORT|g")

# -- Install service (requires sudo for /etc/systemd)
echo "  Installing service (sudo required for /etc/systemd)..."
echo "$GENERATED" | sudo tee "$SERVICE_FILE" > /dev/null

# -- Reload and enable
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

# -- Stop if already running
if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
  echo "  Stopping existing instance..."
  sudo systemctl stop "$SERVICE_NAME"
fi

# -- Start
echo "  Starting NetWatch..."
sudo systemctl start "$SERVICE_NAME"
sleep 2

# -- Status check
if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
  echo ""
  echo "  NetWatch is running!"
  # Try to get local IP
  LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "your-pi-ip")
  echo "  Access: http://${LOCAL_IP}:${NW_PORT}"
  echo ""
  echo "  Useful commands:"
  echo "    sudo systemctl status $SERVICE_NAME   # check status"
  echo "    sudo systemctl stop $SERVICE_NAME     # stop"
  echo "    sudo systemctl restart $SERVICE_NAME  # restart"
  echo "    sudo journalctl -u $SERVICE_NAME -f   # live logs"
  echo ""
  echo "  Don't forget to run ./install.sh to install the Ookla speedtest binary!"
  echo ""
else
  echo ""
  echo "  ERROR: NetWatch failed to start. Check logs:"
  echo "    sudo journalctl -u $SERVICE_NAME -n 20"
  echo ""
  sudo systemctl status "$SERVICE_NAME" --no-pager || true
  exit 1
fi
