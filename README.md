# NetWatch

**ISP speed monitor with dual speedtest — Ookla last-mile + Cloudflare international**

Monitor your internet connection 24/7. Automated tests, dropout detection, 14-day heatmap, privacy mode. Zero npm dependencies. Your data stays on your device.

Built in Kampot, Cambodia by [ced·watch](https://ced.watch)

---

## Features

- **Dual speedtest** — Ookla (closest server, last-mile) then Cloudflare (international backbone), sequentially per cycle
- **Burst mode** — 6 tests at 5-min intervals, then auto-revert to 30 min (avoids Cloudflare rate limiting)
- **14-day dropout heatmap** — visual mosaic of connection quality by hour, touch/hover tooltips
- **Charts** — Download/Upload/Ping over 24h, 7d, 30d with Ookla and Cloudflare overlaid
- **12 KPI boxes** — paired Ookla + Cloudflare side by side on mobile
- **Test History** — full table with filters (Drops, Hi Ping, OK, Partial), CF UL column
- **Privacy mode** — Tailscale-only access with real iptables enforcement (blocks LAN)
- **3 skins** — Kampot (dark green), Mekong (amber), Kep (light)
- **Persistent data** — 90-day rolling `data.json`, survives restarts
- **Self-update** — check and install updates from GitHub releases
- **Systemd service** — auto-start on boot, auto-restart on crash

---

## Requirements

- Linux (Raspberry Pi OS, Ubuntu, Debian, TwisterOS, Umbrel)
- Node.js 18+
- ARM64 / ARMv7 / x86_64

---

## Install — Standalone (any Linux)

```bash
# 1. Clone
git clone https://github.com/cedwatch/netwatch
cd netwatch

# 2. Install Ookla speedtest binary
bash install.sh

# 3. Install and start as a system service
bash setup.sh 5218
```

Open `http://your-device-ip:5218`

That's it. NetWatch starts at boot and restarts automatically if it crashes.

### Update

```bash
cd netwatch
git pull
sudo systemctl restart netwatch
```

### Uninstall

```bash
bash uninstall.sh
```

---

## Install — Umbrel

Install via the **ced·watch Community App Store**:

1. Umbrel UI → App Store → Community App Stores → Add store
2. Enter: `https://github.com/cedwatch/umbrel-community-app-store`
3. Install **NetWatch**

Port: `5218` — data persisted in Umbrel app-data directory.

---

## Configuration

Open the **⚙ Settings panel** in the UI:

| Setting | Description |
|---|---|
| View | 24h / 7d / 30d window |
| Both / Ookla / CF | Show both providers or one |
| Min Mbps / ms | Dropout and high-ping thresholds |
| Test interval | 5m (burst) / 30m / 1h / 3h / 6h |
| Pause | Suspend automated tests |
| Tailscale IP | Your `100.x.x.x` Tailscale address |
| Access toggle | LAN + Tailscale (default) or Tailscale Only |
| Check updates | Compare current vs latest GitHub release |

Settings and thresholds are persisted in `config.json` and survive restarts.

---

## Privacy — Tailscale Only mode

When enabled, NetWatch uses `iptables` to block all non-Tailscale access to its port:

```
sudo iptables -I INPUT -p tcp --dport 5218 ! -s 100.x.x.x -j DROP
```

**Requirements:**
- Tailscale installed on the device (`curl -fsSL https://tailscale.com/install.sh | sh`)
- `setup.sh` already run (adds the necessary sudoers rule)

Enter your Tailscale IP (`100.x.x.x`) in the Settings panel, then toggle **Tailscale Only**. The rule is restored automatically on reboot.

---

## Data

- `data.json` — test records, 90-day rolling window
- `config.json` — settings, skin, thresholds, Tailscale config
- `bin/speedtest` — Ookla CLI binary (installed by `install.sh`)

When running in Docker (Umbrel), data is stored in the mounted volume, not in the container.

---

## License

MIT — [ced·watch](https://ced.watch) · [GitHub](https://github.com/cedwatch)
