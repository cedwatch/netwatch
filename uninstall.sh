#!/usr/bin/env bash
# NetWatch - uninstall.sh
# Removes the systemd service

SERVICE_NAME="netwatch"

echo ""
echo "  NetWatch Uninstall"
echo ""

if sudo systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
  echo "  Stopping service..."
  sudo systemctl stop "$SERVICE_NAME"
fi

if sudo systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
  echo "  Disabling service..."
  sudo systemctl disable "$SERVICE_NAME"
fi

if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
  echo "  Removing service file..."
  sudo rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
  sudo systemctl daemon-reload
fi

echo "  Done. NetWatch service removed."
echo "  Your data.json and config.json are preserved in the install folder."
echo ""
