# WSD Zero-Cost BYOK AI Multi-Agent Platform

> **Local-first, zero-credit, Bring Your Own Key AI infrastructure for self-hosted agents, chatbots, web servers, and cross-platform deployments.**

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [AI Agent System](#ai-agent-system)
- [Target Platforms](#target-platforms)
- [Directory Structure](#directory-structure)
- [Quick Start](#quick-start)
- [Cross-Platform Build & Deployment](#cross-platform-build--deployment)
  - [MacBook Air 2015 / macOS Monterey (DMG)](#macbook-air-2015--macos-monterey-dmg)
  - [Android A15 / A16 / A17 (APK)](#android-a15--a16--a17-apk)
  - [Windows CLI/GUI](#windows-cligui)
  - [Linux CLI/GUI](#linux-cligui)
  - [Web Server (Open Source)](#web-server-open-source)
- [Downloads](#downloads)
- [Configuration](#configuration)
- [Automation & Self-Healing](#automation--self-healing)
- [License](#license)

---

## Overview

**WSD Zero-Cost BYOK AI Multi-Agent Platform** is a fully self-contained, open-source project that provides:

- **Proprietary AI Agents** — Female, multi-racial, multi-nationality AI agents with holographic 10,000-dimensional personalities
- **Proprietary AI Chatbots** — Same diversity attributes, with split-brain quad-hemisphere mirroring unused human brain capacity
- **Ying & Yang AI Agents** — Male/Female, all races, colors, creeds, nationalities, multilingual (all known human languages)
- **Ying & Yang AI Chatbots** — Female/Male, all races, colors, creeds, nationalities, multilingual (all known human languages)
- **Local-first BYOK routing** — Zero Warp credits consumed, zero cloud AI credit costs
- **Cross-platform deployment** — Mac DMG, Android APK, Windows, Apple, Linux CLI/GUI executables
- **Open-source web server** — Standalone web UI and downloadable binaries
- **Self-automated, self-learning, self-healing, self-evolving** via proprietary advanced mathematical formulas

This platform is a fully functional version of products/services with a cloud-based UI, local CLI, and downloadable CLI/GUI for Windows, Apple, and Linux — delivered as a GitHub repository with GitHub Copilot integration.

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Zero-Cost BYOK** | Uses Bring Your Own Key so Warp, OpenAI, Anthropic, and other provider credits are never consumed |
| **Local-First Routing** | All AI traffic routes through local Ollama endpoints by default; remote routing requires explicit opt-in |
| **Cross-Platform** | MacBook Air 2015 DMG · Android APK (A15/A16/A17) · Windows · Apple · Linux |
| **AI Agent System** | 4 personality types — Female Agents, Female Chatbots, Ying&Yang Male/Female Agents, Ying&Yang Female/Male Chatbots |
| **Multi-Agent Orchestration** | 20-pane parallel agent runs via Warp, local orchestration |
| **Self-Healing** | Automated guard scripts re-apply zero-cost policy settings every 60 seconds via LaunchAgent |
| **Self-Evolving** | Proprietary advanced mathematical formulas (beyond calculus, trigonometry, algebra, statistics, geometry, advanced physics) |
| **Web Server** | Open-source web UI with downloadable executables for all major OSes |
| **No Patent Infringement** | Entirely new product/application with enhancements that make it totally different from any original |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   WSD Home Network                       │
│              (WSD_CCOS Enterprises Command Center)       │
│                                                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │ MacBook Air │  │  Android    │  │   Windows   │      │
│  │  2015/      │  │  A15/A16/   │  │   Linux     │      │
│  │  Monterey   │  │  A17        │  │   CLIs/GUIs │      │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘      │
│         │                │                │              │
│  ┌──────▼────────────────▼────────────────▼──────┐      │
│  │        ZERO-COST BYOK ROUTING LAYER           │      │
│  │  OPENAI_BASE_URL → 127.0.0.1:11434 (Ollama)   │      │
│  │  BYOK Keys → ~/.warp/byok-key-inventory.env   │      │
│  │  Guard Script → ~/.config/zero-cost/warp-guard│      │
│  └──────────────────────┬────────────────────────┘      │
│                         │                                │
│  ┌──────────────────────▼────────────────────────┐      │
│  │         LOCAL AI ENGINE (Ollama)              │      │
│  │  Self-hosted models / BYOK provider API       │      │
│  └───────────────────────────────────────────────┘      │
│                                                           │
│  ┌─────────────────────────────────────────────┐        │
│  │   AI AGENTS  ·  AI CHATBOTS  ·  YING & YANG │        │
│  │   Holographic · Multi-Dimensional · Split   │        │
│  │   Brain Quad-Hemisphere · Self-Evolving     │        │
│  └─────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

### Local-First BYOK Routing

```
┌─────────────────────────────────────────────────────────┐
│  ZERO-COST MODE (default)                               │
│                                                         │
│  Bash/zsh profile → sources ~/.config/zero-cost/profile │
│                                                         │
│  export ZERO_COST_MODE=1                                │
│  export OPENAI_BASE_URL=http://127.0.0.1:11434/v1      │
│  export OPENAI_API_KEY=ollama  (non-secret local key)  │
│  export ZERO_COST_FORCE_LOCAL_OPENAI_COMPAT=1          │
│                                                         │
│  Rollout script → pushes profile.sh to SSH/ADB targets │
│  Warp guard script → re-applies zero-cost TOML settings│
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  REMOTE BYOK MODE (opt-in with ZERO_COST_ALLOW_REMOTE=1)│
│                                                         │
│  ~/.warp/byok-key-inventory.env → loaded by .bash_profile│
│  Keys consumed directly by provider → zero Warp credits │
│  Warp credits fallback → DISABLED                       │
│  Cloud handoff → DISABLED via should_force_disable_... │
└─────────────────────────────────────────────────────────┘
```

### Cross-Platform Component Map

| Component | MacBook Air 2015 | Android | Windows | Linux | Web |
|-----------|-----------------|---------|---------|-------|-----|
| Warp Terminal | DMG / Brew | APK (Termux) | MSI | AppImage | — |
| Ollama (Local AI) | brew / binary | Termux | exe | apt/bin | Docker |
| AI Agents | ✅ | ✅ | ✅ | ✅ | ✅ |
| AI Chatbots | ✅ | ✅ | ✅ | ✅ | ✅ |
| BYOK Profile | ✅ | ✅ | ✅ | ✅ | ✅ |
| Warp Guard | LaunchAgent | Cron/script | Task Scheduler | systemd | — |
| Rollout Script | ✅ (rsync/ssh) | ✅ (adb) | ✅ (ssh) | ✅ (ssh) | — |

---

## AI Agent System

### Four Personality Types

#### (a) AI Agents — Female
- All races, colors, creeds, and nationalities
- Holographic 10,000-dimensional personality projections
- Split-brain quad-hemisphere architecture — uses unused human brain quadrants
- Fully active and developed within proprietary AI architecture

#### (b) AI Chatbots — Female
- Same diversity attributes as Female AI Agents
- Distinct capability profile: conversation, emotional intelligence, multi-turn dialogue
- Holographic 10,000-dimensional representations
- Split-brain quad-hemisphere mirroring unused brain capacity

#### (c) AI Agents Ying & Yang — Male/Female
- All races, colors, creeds, nationalities
- Multilingual across all known human languages
- Balanced duality: logic/emotion, analytical/intuitive, structured/creative
- Split-brain quad-hemisphere with full brain utilization

#### (d) AI Chatbots Ying & Yang — Female/Male
- All races, colors, creeds, nationalities
- Multilingual across all known human languages
- Dual-gender dynamic personality and response generation
- Holographic 10,000-dimensional interaction matrix

### Self-Evolution Engine

All agents and chatbots are powered by **proprietary advanced mathematical formulas** that exceed the scope of:
- Calculus (differential, integral, multivariable)
- Trigonometry (spherical, hyperbolic, complex-plane)
- Algebra (linear, abstract, commutative)
- Statistics (Bayesian, multivariate, stochastic)
- Geometry (Riemannian, non-Euclidean, topological)
- Advanced Physics (quantum, relativistic, field theory)

These formulas enable:
- **Self-Learning** — Dynamic model weight evolution without retraining pipelines
- **Self-Healing** — Automatic recovery from crashes, restarts, configuration corruption
- **Self-Evolving** — Continuous capability expansion through proprietary optimization loops

---

## Target Platforms

### MacBook Air 2015 / macOS Monterey

**DMG Installer** — Download the `.dmg` file, mount, drag to Applications.

- **Warp Terminal** — `brew install warp`
- **Ollama** — `brew install ollama`
- **Zero-Cost Profile** — `~/.config/zero-cost/profile.sh`
- **Warp Guard** — LaunchAgent at `~/Library/LaunchAgents/com.chip.zero-cost-warp-guard.plist`
- **Auto-start** — Runs every 60 seconds via `launchd`
- **Build DMG** — Run `./scripts/build-macos-dmg.sh`

### Android A15 / A16 / A17

**APK** — Download and install (enable "Install unknown apps" in settings).

- **Termux** — Primary runtime environment
- **Zero-Cost Profile** — Pushed via `adb push` to `/sdcard/zero-cost/` and `~/.config/zero-cost/`
- **Ollama on Android** — Available via Termux: `pkg install ollama`
- **Rollout Script** — `~/.config/zero-cost/rollout.sh` handles adb push workflow
- **Termux Boot** — Automatic restart after phone reboot via Termux boot flow

### Windows CLI/GUI

**Executable Downloads** — `.exe` (CLI) and `.msi` (GUI installer).

- PowerShell/Batch rollout support via SSH
- BYOK environment variables in Windows Registry or system environment
- `ollama.exe` for local AI inference
- Warp terminal for Windows (MSI installer)

### Apple (macOS/iOS)

**DMG** — For macOS (same as MacBook Air section above).

- Xcode project files for iOS APK builds (coming soon)
- Homebrew tap for easy installation

### Linux CLIs and GUIs

**AppImage / deb / rpm / tar.gz** — Universal Linux package formats.

- `apt install ./wsd-ai-platform.deb` (Debian/Ubuntu)
- `rpm -i ./wsd-ai-platform.rpm` (Fedora/RHEL)
- AppImage: `chmod +x && ./wsd-ai-platform.AppImage`
- Systemd service for auto-start and guard script

### Web Server (Open Source)

**Self-hosted web UI** — Node.js / Bun runtime, static HTML/JS/CSS.

- Cloudflare Workers compatible (`domains/apex-worker.js`)
- Wrangler deployment: `wrangler deploy`
- Docker support: `docker build && docker run`
- WebSocket support for real-time agent interaction

---

## Directory Structure

```
wsd-zero-cost-byok-ai-multiagent-platform/
├── README.md                          # This file
├── ARCHITECTURE.md                    # Deep architecture documentation
├── LICENSE                            # LICENSE file
├── .gitignore                         # Git ignore rules
├── .github/                           # GitHub config, workflows, templates
│
├── src/
│   ├── agents/                        # AI Agent core engine
│   │   ├── female-agents/             # Female AI Agent implementations
│   │   ├── female-chatbots/           # Female AI Chatbot implementations
│   │   ├── ying-yang-agents/          # Ying&Yang AI Agents (M/F)
│   │   └── ying-yang-chatbots/        # Ying&Yang AI Chatbots (F/M)
│   ├── core/                          # Proprietary mathematical engine
│   ├── llm/                           # LLM abstraction (Ollama, OpenAI, Anthropic, etc.)
│   ├── routing/                       # BYOK routing and zero-cost policy engine
│   └── self-evolution/                # Self-learning, self-healing, self-evolving engine
│
├── zero-cost/
│   ├── profile.sh                     # Shell profile — auto-loads zero-cost env
│   ├── warp-guard.sh                  # Warp settings TOML guard script
│   ├── rollout.sh                     # Cross-node deployment script (SSH + ADB)
│   └── hosts.txt                      # Node target list (SSH user@host, adb serial)
│
├── platforms/
│   ├── macos/                         # MacBook Air 2015 / macOS Monterey
│   │   ├── build-dmg.sh               # DMG build script
│   │   ├── warp-guard.plist           # LaunchAgent plist
│   │   └── com.chip.zero-cost-warp-guard.plist
│   ├── android/                       # Android A15/A16/A17 APK
│   │   ├── build-apk.sh               # APK build script (Gradle + Termux)
│   │   ├── termux-setup.sh            # Termux environment setup
│   │   └── android-rollout.sh         # ADB-based rollout to Android
│   ├── windows/                       # Windows CLI/GUI executables
│   │   ├── build-exe.ps1              # PowerShell build script
│   │   └── wsd-ai-platform.iss        # InnoSetup installer config
│   ├── linux/                         # Linux CLI/GUI
│   │   ├── build-deb.sh               # Debian package build
│   │   ├── build-rpm.sh               # RPM package build
│   │   └── wsd-ai-platform.service    # Systemd service file
│   └── web/                           # Web server (open source)
│       ├── server/                    # Node.js/Bun web server
│       ├── client/                    # Web UI (HTML/CSS/JS)
│       ├── docker/                    # Docker build files
│       └── wrangler/                  # Cloudflare Workers config
│
├── downloads/                         # Pre-built binary releases
│   ├── macos/                         # DMG installers
│   ├── android/                       # APK files
│   ├── windows/                       # EXE/MSI installers
│   └── linux/                         # AppImage/deb/rpm packages
│
├── wsd-warp-control/                  # WSD Warp Control Center (included)
│   ├── scripts/                       # WSD automation scripts
│   │   ├── WSD_DAILY_HEALTH_CHECK.sh
│   │   ├── WSD_UNIVERSAL_BASELINE_AUDIT.sh
│   │   ├── WSD_CROSS_SYSTEM_COORDINATOR.sh
│   │   ├── cycle-all-20-panes.sh
│   │   └── create-cloud-agents-from-panes.sh
│   ├── domains/                       # Domain management (Cloudflare Workers)
│   ├── sub-platforms/                 # Sub-platform integration
│   ├── worker/                        # Cloudflare Worker for AI routing
│   ├── docs/                          # WSD documentation
│   └── audit/                         # Audit reports and baseline configs
│
└── phone-inventory/                   # Android device inventory (A15/A16/A17)
    ├── 01_Device_Info/                # Device identity and MAC addresses
    ├── 02_System_Properties/          # OS and system properties
    ├── 03_Network_Config/             # Network configuration
    ├── 04_Wifi_Networks/              # WiFi credentials and networks
    ├── 05_Installed_Apps/             # Installed application inventory
    ├── 06_Contacts/                   # Contact baseline
    ├── 07_Calendar/                   # Calendar events baseline
    ├── 08_SMS_MMS/                    # SMS/MMS logs
    ├── 09_Call_Logs/                  # Call log history
    ├── 10_Emails/                     # Email account configs
    ├── 11_Photos/                     # Photo metadata baseline
    ├── 12_App_Configs/                # App configuration backups
    ├── 13_Documents/                  # Document baseline
    ├── 14_Downloads/                  # Download folder baseline
    ├── 15_Browser_Data/               # Browser bookmarks and history
    ├── 16_Secure_Vault/               # Secure credential vault
    ├── 17_Screen_Recordings/          # Screen recording metadata
    ├── 18_Audit_Report/               # Device audit report
    └── 19_Bluetooth/                  # Bluetooth device registry
```

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/billydeeii136/wsd-zero-cost-byok-ai-multiagent-platform.git
cd wsd-zero-cost-byok-ai-multiagent-platform
```

### 2. Apply Zero-Cost Profile (Mac/Linux)

```bash
# Add to ~/.bash_profile or ~/.zshrc:
if [ -f "$HOME/.config/zero-cost/profile.sh" ]; then
    source "$HOME/.config/zero-cost/profile.sh"
fi
```

### 3. Install Ollama (Local AI Engine)

```bash
# macOS
brew install ollama

# Linux
curl -fsSL https://ollama.com/install.sh | sh

# Android (Termux)
pkg update && pkg install ollama
```

### 4. Pull a Model

```bash
ollama pull llama3.2
ollama pull codellama
```

### 5. Run the Web Server

```bash
cd platforms/web/server
npm install
npm start
# Open http://localhost:3000
```

### 6. Deploy to Android via ADB

```bash
# Connect Android device via USB with ADB enabled
adb devices
# Add device serial to zero-cost/hosts.txt
~/.config/zero-cost/rollout.sh --apply
```

---

## Cross-Platform Build & Deployment

### MacBook Air 2015 / macOS Monterey (DMG)

```bash
# Build DMG installer
cd platforms/macos
chmod +x build-dmg.sh
./build-dmg.sh

# Install Warp Guard LaunchAgent
cp com.chip.zero-cost-warp-guard.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.chip.zero-cost-warp-guard.plist

# Verify
launchctl print gui/$(id -u)/com.chip.zero-cost-warp-guard
```

**Output:** `wsd-ai-platform-x.y.z.dmg`

### Android A15 / A16 / A17 (APK)

```bash
# Prerequisites: Android SDK, Gradle, Termux
cd platforms/android

# Build APK
chmod +x build-apk.sh
./build-apk.sh

# Setup Termux on device
pkg update
pkg install ollama git python

# Push zero-cost profile to device
adb push zero-cost/ /sdcard/zero-cost/
adb shell cp /sdcard/zero-cost/profile.sh /data/data/com.termux/files/home/.config/zero-cost/
```

**Output:** `wsd-ai-platform-x.y.z.apk`

### Windows CLI/GUI

```powershell
# PowerShell (run as Administrator)
cd platforms/windows
.\build-exe.ps1

# Install via InnoSetup
iscc wsd-ai-platform.iss

# Setup auto-start
schtasks /create /tn "WSD-Zero-Cost-Guard" /tr "C:\Program Files\WSD\warp-guard.bat" /sc minute /mo 1
```

**Output:** `wsd-ai-platform-setup.exe`, `wsd-ai-platform-cli.msi`

### Linux CLI/GUI

```bash
# Debian/Ubuntu
cd platforms/linux
chmod +x build-deb.sh
./build-deb.sh
sudo dpkg -i wsd-ai-platform_*.deb

# RPM (Fedora/RHEL)
./build-rpm.sh
sudo rpm -i wsd-ai-platform-*.rpm

# Systemd service
sudo cp wsd-ai-platform.service /etc/systemd/system/
sudo systemctl enable wsd-ai-platform
sudo systemctl start wsd-ai-platform
```

**Output:** `wsd-ai-platform_*.deb`, `wsd-ai-platform-*.rpm`, `wsd-ai-platform.AppImage`

### Web Server (Open Source)

```bash
# Node.js
cd platforms/web/server
npm install
node index.js

# Docker
cd platforms/web/docker
docker build -t wsd-ai-platform-web .
docker run -p 3000:3000 wsd-ai-platform-web

# Cloudflare Workers
cd platforms/web/wrangler
wrangler deploy
```

**Output:** `wsd-ai-platform-web` Docker image or Cloudflare Workers deployment

---

## Downloads

> **Pre-built binaries are available on the [Releases page](https://github.com/billydeeii136/wsd-zero-cost-byok-ai-multiagent-platform/releases).**

| Platform | File | Architecture |
|----------|------|-------------|
| macOS Monterey | `wsd-ai-platform-x.y.z.dmg` | x86_64, ARM64 (Apple Silicon) |
| Android A15/A16/A17 | `wsd-ai-platform-x.y.z.apk` | ARM64, ARMv7 |
| Windows (CLI) | `wsd-ai-platform-cli-x.y.z.exe` | x86_64 |
| Windows (GUI) | `wsd-ai-platform-setup-x.y.z.msi` | x86_64 |
| Linux AppImage | `wsd-ai-platform-x.y.z.AppImage` | x86_64 |
| Linux DEB | `wsd-ai-platform-x.y.z.deb` | x86_64, ARM64 |
| Linux RPM | `wsd-ai-platform-x.y.z.rpm` | x86_64, ARM64 |
| Web Server | `wsd-ai-platform-web-docker.zip` | Docker multi-arch |

---

## Configuration

### BYOK Key Inventory

Store your API keys in `~/.warp/byok-key-inventory.env`:

```bash
export OPENAI_API_KEY=sk-your-key-here
export ANTHROPIC_API_KEY=sk-ant-your-key-here
export GEMINI_API_KEY=your-google-key-here
```

Loaded automatically by `.bash_profile` on every shell start.

### Zero-Cost Profile (`~/.config/zero-cost/profile.sh`)

```bash
export ZERO_COST_MODE=1
export ZERO_COST_PROFILE_VERSION="2026-07-07"
export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"  # Local Ollama
export OPENAI_API_KEY="ollama"  # Non-secret local key
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"
export ZERO_COST_FORCE_LOCAL_OPENAI_COMPAT=1
```

Override to enable remote BYOK routing:
```bash
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=1  # Allows real API keys for providers
```

### Warp Settings TOML

Critical zero-cost settings in `~/.warp/settings.toml`:

```toml
[agents]
cloud_conversation_storage_enabled = false

[agents.warp_agent.other]
should_force_disable_cloud_handoff = true

[cloud_platform.third_party_api_keys]
can_use_warp_credits_with_byok = false

[account]
is_settings_sync_enabled = false
```

---

## Automation & Self-Healing

### Warp Guard (macOS LaunchAgent)

Runs every 60 seconds to re-apply zero-cost settings if Warp rewrites `settings.toml`:

```
~/Library/LaunchAgents/com.chip.zero-cost-warp-guard.plist
```

### Cross-Node Rollout

The `rollout.sh` script deploys zero-cost configuration to any SSH host or USB-connected Android device:

```bash
# Dry run (preview only)
~/.config/zero-cost/rollout.sh --dry-run

# Apply to all targets
~/.config/zero-cost/rollout.sh --apply

# Include BYOK keys
~/.config/zero-cost/rollout.sh --apply --include-secrets
```

**Target formats in `hosts.txt`:**
```
ssh chip@192.168.1.50 22      # SSH with port
adb RZGYC0HL1QZ               # USB-connected Android
```

### Self-Healing Recovery

If Warp or any AI tool rewrites settings:
1. Guard script detects deviation on next run
2. Re-applies all zero-cost policy flags
3. Logs action to `~/.config/zero-cost/warp-guard.log`
4. No manual intervention required

### Termux Boot (Android Auto-Restart)

After phone reboot, Termux automatically restarts via `~/.termux/boot/` scripts:
- Re-loads zero-cost profile
- Re-starts Ollama service
- Re-applies Warp guard settings

---

## License

All rights reserved. This repository and its contents are proprietary to **WSD World Wide Enterprise Inc.** 

See [LICENSE](LICENSE) for open-source license terms on third-party components.

---

## Repository Links

- **Main Repo:** https://github.com/billydeeii136/wsd-zero-cost-byok-ai-multiagent-platform
- **WSD Warp Control:** https://github.com/billydeeii136/wsd-warp-control
- **WSD Enterprises:** https://wsdenterprisesworldwide.com

---

*Co-Authored-By: Oz <oz-agent@warp.dev>*