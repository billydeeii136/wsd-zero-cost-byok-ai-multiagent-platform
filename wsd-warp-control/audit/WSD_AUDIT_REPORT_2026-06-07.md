# WSD Cross-System Audit Report
## Comprehensive System Dependencies, Credentials & Automation Mapping

**Report Generated:** 2026-06-07T07:39:00Z  
**System:** MacBook-Air (MacBookAir7,1)  
**User:** billydeeii136 (UID: 501)  
**macOS:** 12.7.6 (Build 21H1320)  
**Audit Source:** `WSD_UNIVERSAL_BASELINE_AUDIT.sh`  
**Repository:** `billydeeii136/wsd-warp-control`  
**Commit:** `910c5ac`

---

## Executive Summary

This report maps all system dependencies, credential stores, automation schedules, and cross-system integrations across the WSD ecosystem. It serves as the baseline for governance discussions and gatekeeping policy enforcement.

| Domain | Status | Risk Level |
|---|---|---|
| Disk Health | 60% usage, 9.6Gi available | 🟢 Low |
| Shell Lock | `/bin/bash` enforced | 🟢 Low |
| Browser Security | Chrome tuned, all others optimized | 🟢 Low |
| VS Code State | 65 extensions, 0 duplicates | 🟢 Low |
| Credential Isolation | 8 env secrets detected, 2 key managers | 🟡 Medium |
| Cloudflare Tunnels | 3 active tunnels | 🟢 Low |
| GitHub Sync | 22 repos, all private | 🟢 Low |
| Google Drive | 3 mounts, 119G Library folder | 🟡 Medium |
| Cron Governance | 3 jobs active, 8 LaunchAgents | 🟡 Medium |
| System Processes | 347 total, WARP using 54% CPU | 🔴 High |

---

## 1. System Hardware & Identity

| Property | Value | Notes |
|---|---|---|
| Hostname | `MacBook-Air.local` | — |
| Model | MacBookAir7,1 | 2015 MacBook Air, 4GB RAM |
| CPU Cores | 4 | Intel Core i5 |
| Physical Memory | 4.00 GB | Limited — impacts multitasking |
| Battery | AC Power connected | Desktop mode active |
| Uptime | 22h 47m | Stable since last boot |

**⚠️ Risk:** 4GB RAM is a constraint for 65 VS Code extensions + multiple browsers + WARP + cloud services. Memory pressure will be a recurring issue.

---

## 2. Operating System & Shell

| Component | Version | Configuration | Dependency Chain |
|---|---|---|---|
| macOS | 12.7.6 (Monterey) | Build 21H1320 | Base OS |
| Kernel | 21.6.0 | Darwin x86_64 | System calls |
| Bash | 5.3.12(1) | Default shell, Terminal locked | All scripts |
| zsh | 5.8.1 | Present but secondary | macOS default fallback |

**Shell Lock Chain:**
```
Terminal.app default → /bin/bash (enforced via defaults)
All scripts → #!/bin/bash (enforced via script headers)
VS Code terminal → /bin/bash (enforced in settings.json)
```

---

## 3. Disk & Storage Dependencies

### Primary Partition (APFS)

| Device | Mount | Size | Used | Available | Usage |
|---|---|---|---|---|---|
| `/dev/disk1s5s1` | `/` | 233Gi | 14Gi | 9.6Gi | 60% |
| `/dev/disk1s4` | `/System/Volumes/VM` | 233Gi | 38Gi | 9.6Gi | 18% |
| `/dev/disk1s2` | `/System/Volumes/Preboot` | 233Gi | 7.0Gi | 9.6Gi | 3% |
| `/dev/disk1s6` | `/System/Volumes/Update` | 233Gi | 2.3Gi | 9.6Gi | 1% |
| `/dev/disk1s1` | `/System/Volumes/Data` | 233Gi | 206Gi | 9.6Gi | 96% |

**⚠️ CRITICAL:** `/System/Volumes/Data` at 96% — this is where user data lives. The 9.6Gi "available" is shared across all APFS volumes. The 96% on Data indicates the root disk container is near full, even though `/` shows 60%.

### User Directory Sizes

| Directory | Size | Dependency | Notes |
|---|---|---|---|
| `~/Library/` | 119G | All apps, caches, configs | Largest consumer |
| `~/Desktop/` | 948M | Working files | — |
| `~/Documents/` | 5.7M | Documents | Small |
| `~/Pictures/` | 13M | Photos | Small |
| `~/Movies/` | 28K | Videos | Near empty |
| `~/Music/` | 244K | Audio | Near empty |
| `~/Downloads/` | 0 bytes (symlinks) | Google Drive cloud refs | All offloaded |

### Google Drive Mounts

| Mount | Path | Status | Sync |
|---|---|---|---|
| Primary | `GoogleDrive-williamscottdavis136@gmail.com` | Active | Bidirectional |
| Secondary | `GoogleDrive-` | Active | Secondary account |
| Tertiary | `GoogleDrive` | Active | Legacy mount |

**Offload Lanes (Codex Structure):**

| Lane | Files | Purpose |
|---|---|---|
| `01_Downloads_Hourly` | 2 | Browser download offloads |
| `02_Large_Files` | 0 | >50MB immediate moves |
| `03_Installers_DMG` | 0 | .dmg, .pkg, .exe files |
| `04_Images_Media` | 0 | .jpg, .png, .mp4, .mov |
| `05_Archive_ZIP` | 0 | .zip, .tar.gz, .7z |
| `06_Scripts_Terminal` | 66 | Old `.sh` files |
| `07_VSCode_Workspaces` | 0 | .code-workspace backups |
| `08_Misc` | 0 | Catch-all |

---

## 4. Credential & Secrets Mapping

### 🔒 Present But Isolated (No Values Exposed)

| Store | Type | Location | Accessed By | Risk |
|---|---|---|---|---|
| macOS Keychain | `login.keychain-db`, `System.keychain` | `~/Library/Keychains/` | System, 1Password, Bitwarden | 🟢 Low |
| SSH Keys | `id_ed25519` | `~/.ssh/` | Git, SSH tunnels | 🟡 Medium |
| Environment Variables | 8 secrets | Shell env | Scripts, CLIs | 🟡 Medium |
| 1Password App | Password manager | `/Applications/1Password.app` | Browser extensions | 🟢 Low |
| Bitwarden App | Password manager | `/Applications/Bitwarden.app` | Browser extensions | 🟢 Low |
| Wrangler Config | Cloudflare auth | `~/.wrangler/`, `~/.config/` | Wrangler CLI | 🟡 Medium |
| GitHub CLI | `gh` auth | `~/.config/gh/` | Git operations | 🟡 Medium |
| gcloud ADC | GCP credentials | `~/Library/Application Support/gcloud/` | gcloud CLI | 🟡 Medium |

### Environment Secrets Detected (Names Only)

```
WSD_CLOUDFLARE_API_TOKEN
OPENAI_API_KEY
GH_TOKEN
GITHUB_TOKEN
WSD_OPENAI_API_KEY
WSD_GITHUB_TOKEN
CLOUDFLARE_API_TOKEN
CF_API_TOKEN
```

**⚠️ Risk:** 8 API tokens in environment variables. If any script logs `env` or `printenv`, these could be leaked. Current scripts do NOT log env values, but any new script could.

### Credential Isolation Rules (Enforced)

1. No AI system (WARP, Codex, ChatGPT, Claude) may harvest or export credentials
2. No script logs `env` values — only presence/absence
3. All password managers stay in native apps (1Password, Bitwarden, iCloud Keychain)
4. SSH keys never leave `~/.ssh/`
5. `.gitignore` blocks all `*.env`, `*.key`, `*.pem`, `vault/` files

---

## 5. Application Inventory (101 Installed)

### Browsers (8)

| Application | Version | Status | CPU | Memory | Optimized |
|---|---|---|---|---|---|
| Google Chrome | 148.0.7778.216 | Running (PID 86085) | 0.1% | 0.9% | ✅ Cache 128MB, Background OFF, Hardware Accel ON |
| Firefox | 140.10.0esr | Not running | — | — | ✅ 2 profiles tuned, tab unloading ON |
| Safari | 17.6 | Not running | — | — | ✅ Caches cleared, plugins/Java disabled |
| Opera | Not installed | — | — | — | ✅ Background OFF, hardware accel ON (when running) |
| DuckDuckGo | App installed | Not running | — | — | ✅ No tuning needed |
| Microsoft Edge | Not installed | — | — | — | N/A |

### Development Tools (6)

| Application | Version | Role | Dependency |
|---|---|---|---|
| Visual Studio Code | 1.123.0 | Primary IDE | 65 extensions, bash terminal |
| Docker | 29.5.3 | Containerization | Not actively used |
| Postman | Installed | API testing | — |
| Codex | CLI installed | AI coding assistant | `~/.npm-global/bin/codex` |
| iTerm | Installed | Terminal alternative | — |
| Xcode | Not installed | — | — |

### Cloud & Sync Tools (5)

| Application | Status | Role | Dependency |
|---|---|---|---|
| Google Drive | Running | File sync, offload target | All automation |
| Cloudflare WARP | Running | VPN, tunnel | `cloudflared`, secure access |
| Dropbox | Not running | Legacy sync | — |
| 1Password | Running | Password manager | Browser extensions |
| Bitwarden | Running | Password manager | Browser extensions |

### AI & Assistant Tools (7+)

| Application | Type | VS Code Extension | Status |
|---|---|---|---|
| WARP (Oz) | AI Agent | N/A | Active (54% CPU — high) |
| Codex CLI | AI Coding | N/A | Installed |
| Claude Code | AI Coding | `anthropic.claude-code` | Extension installed |
| GitHub Copilot | AI Coding | `github.vscode-pull-request-github` | Extension installed |
| Amazon Q | AI Coding | `amazonwebservices.amazon-q-vscode` | Extension installed |
| Codeium | AI Coding | `codeium.codeium` | Extension installed |
| Augment | AI Coding | `augment.vscode-augment` | Extension installed |
| CodeRabbit | AI Coding | `coderabbit.coderabbit-vscode` | Extension installed |
| ChatGPT | AI Coding | `openai.chatgpt` | Extension installed |
| Supermaven | AI Coding | `supermaven.supermaven` | Extension installed |
| Roo Cline | AI Coding | `rooveterinaryinc.roo-cline` | Extension installed |
| Console Ninja | Dev tool | `wallabyjs.console-ninja` | Extension installed |
| Google Cloud Code | Cloud | `googlecloudtools.cloudcode` | Extension installed (352MB) |
| Gemini Code Assist | AI Coding | `google.geminicodeassist` | Extension installed (287MB) |
| Azure Copilot | AI Coding | `ms-azuretools.vscode-azure-github-copilot` | Extension installed |
| Azure MCP Server | AI/Cloud | `ms-azuretools.vscode-azure-mcp-server` | Extension installed |
| Windows AI Studio | AI/ML | `ms-windows-ai-studio.windows-ai-studio` | Extension installed |
| AI Foundry | AI/ML | `teamsdevapp.vscode-ai-foundry` | Extension installed |
| Qwen Code | AI Coding | `qwenlm.qwen-code-vscode-ide-companion` | Extension installed |
| LiteLLM | AI/LLM | `vivswan.litellm-vscode-chat` | Extension installed |
| Ollama Codex | AI/Local | `kparth01.ollama-codex` | Extension installed |
| Llama VS Code | AI/Local | `maruf-bepary.llama-vscode-chat` | Extension installed |
| Claude Dev | AI Coding | `saoudrizwan.claude-dev` | Extension installed (54MB) |
| Claude Runner | AI Coding | `codingworkflow.claude-runner` | Extension installed |
| Claude Code Chat Cursor | AI Coding | `waveflow.claude-code-chat-cursor-design` | Extension installed |
| Anthropic Coder | AI Coding | `rizwanansari.anthropic-coder` | Extension installed |
| MCP Client | AI/Agent | `m1self.mcp-client` | Extension installed |
| GitHub Copilot CLI Agents | AI/Agent | `sbluemin.github-copilot-cli-agents` | Extension installed |
| ChatGPT Copilot | AI Coding | `feiskyer.chatgpt-copilot` | Extension installed |
| ChatGPT Web Search | AI/Search | `ms-vscode.vscode-websearchforcopilot` | Extension installed |
| Web Scraping | AI/Data | `zyte.web-scraping` | Extension installed |
| Twilio Integration | AI/Comms | `buildwithlayer.twilio-integration-expert` | Extension installed |
| Parallels Desktop | Dev/VM | `parallelsdesktop.parallels-desktop` | Extension installed |
| .NET Modernize | Dev | `ms-dotnettools.vscode-dotnet-modernize` | Extension installed |
| Java Upgrade | Dev | `vscjava.vscode-java-upgrade` | Extension installed |
| Ruby LSP | Dev | `shopify.ruby-lsp` | Extension installed |
| Markdown Lint | Dev | `davidanson.vscode-markdownlint` | Extension installed |
| Regex Tool | Dev | `chrmarti.regex` | Extension installed |
| Console Ninja | Dev | `wallabyjs.console-ninja` | Extension installed |
| NPM Intellisense | Dev | `christian-kohler.npm-intellisense` | Extension installed |
| Comment Translate | Dev | `intellsmi.comment-translate` | Extension installed |
| SWDC (Software.com) | Dev | `softwaredotcom.swdc-vscode` | Extension installed |
| Jupyter | Data/ML | `ms-toolsai.jupyter` | Extension installed |
| Jupyter Keymap | Data/ML | `ms-toolsai.jupyter-keymap` | Extension installed |
| Jupyter Renderers | Data/ML | `ms-toolsai.jupyter-renderers` | Extension installed |
| Jupyter Cell Tags | Data/ML | `ms-toolsai.vscode-jupyter-cell-tags` | Extension installed |
| Jupyter Slideshow | Data/ML | `ms-toolsai.vscode-jupyter-slideshow` | Extension installed |
| Python Debugpy | Dev | `ms-python.debugpy` | Extension installed |
| Python Pylance | Dev | `ms-python.vscode-pylance` | Extension installed |
| Python Envs | Dev | `ms-python.vscode-python-envs` | Extension installed |
| Azure Repos | Dev | `ms-vscode.azure-repos` | Extension installed |
| Remote Repositories | Dev | `ms-vscode.remote-repositories` | Extension installed |
| Codespaces | Dev | `github.codespaces` | Extension installed |
| RemoteHub | Dev | `github.remotehub` | Extension installed |
| Azure Resource Groups | Cloud | `ms-azuretools.vscode-azureresourcegroups` | Extension installed |
| Azure Containers | Cloud | `ms-azuretools.vscode-containers` | Extension installed |
| Azure Load Testing | Cloud | `ms-azure-load-testing.microsoft-testing` | Extension installed |
| Google Cloud Data | Cloud | `googlecloudtools.datacloud` | Extension installed |
| Keploy | Dev/Test | `keploy.keployio` | Extension installed |
| Local LLM Chat | AI/Local | `markusbegerow.local-llm-chat-vscode` | Extension installed |
| LM Studio BYOK | AI/Local | `nullsetindustries.lmstudio-byok-chat-provider` | Extension installed |
| Cloudflare Workers | Cloud | `—` | Not as extension (Wrangler CLI) |

**⚠️ Risk:** 65 extensions, many are AI coding assistants that may conflict. 10+ AI extensions could compete for the same keyboard shortcuts, inline suggestions, and API keys. This is a known source of VS Code slowdowns.

---

## 6. VS Code Configuration

| Setting | Value | Source |
|---|---|---|
| Shell | `/bin/bash` | `settings.json` → `"terminal.integrated.profiles.osx"` |
| Default Profile | `WSD Bash` | `settings.json` → `"terminal.integrated.defaultProfile.osx"` |
| Theme | `Visual Studio Dark` | `settings.json` |
| Auto Save | `onFocusChange` | `settings.json` |
| Default Formatter | `feiskyer.chatgpt-copilot` | `settings.json` |
| Font Size | 14 | `settings.json` |
| Mouse Wheel Zoom | Enabled | `settings.json` |
| Word Wrap | Enabled | `settings.json` |
| Format On Paste | Enabled | `settings.json` |
| Format On Save | Enabled | `settings.json` |
| Chat Agent Max Requests | 100 | `settings.json` |
| Extension Cache | 508MB | `~/Library/Application Support/Code/CachedExtensionVSIXs/` |
| App Support | 821MB | `~/Library/Application Support/Code/` |
| Extensions Total | 2.8GB | `~/.vscode/extensions/` |

---

## 7. Cloud Infrastructure Dependencies

### Cloudflare (Primary Cloud)

| Service | Status | Configuration | Dependency |
|---|---|---|---|
| Wrangler CLI | 4.98.0 | Configured, API token present | All deployments |
| KV Namespaces | 2 active | `KV_MEMORY`, `KV_STATE` | Worker data |
| D1 Database | 1 | `wsd-enterprises-db` | Structured data |
| Workers (dry-run) | 1 | Domain variable, Lane variable | `wsdenterprisesworldwidecloudservices` |
| Tunnels | 3 active | `MAC`, `my-ssh-tunnel`, `wsd-ccos-tunnel` | Secure access |
| WARP VPN | Running | `cloudflared` daemon active | Network security |
| DNS | 7 domains | Porkbun registrar, Cloudflare DNS | All websites |

**Tunnel Details:**

| ID | Name | Created | Connections |
|---|---|---|---|
| `b4061a30-...` | `MAC` | 2026-04-18 | Active |
| `cffeb8e3-...` | `my-ssh-tunnel` | 2026-04-18 | Active |
| `95a36949-...` | `wsd-ccos-tunnel` | 2026-03-22 | Active |

### Google Cloud Platform (GCP)

| Service | Status | Configuration | Dependency |
|---|---|---|---|
| gcloud SDK | 570.0.0 | Active | `billydeeii136@gmail.com` |
| Project | `wsd-ccos-nexgen-1` | Primary | All GCP resources |
| Services | 10+ enabled | AI Platform, BigQuery, Dataproc, etc. | Data pipelines |
| VMs | 0 active | None running | — |
| ADC | Not present | No `application_default_credentials.json` | Auth via gcloud CLI |

### GitHub

| Property | Value | Dependency |
|---|---|---|
| User | `billydeeii136` | All repos |
| Total Repos | 22 | All projects |
| Primary Repo | `wsd-warp-control` | Automation, scripts, docs |
| Secondary Repo | `codex-wsd-control` | Codex coordination, WSD control |
| Worker Repo | `wsd-cumseeme-live` | Jailed adult platform |
| Domain Repos | 7 | One per domain |
| SSH Key | `id_ed25519` | Git authentication |
| Git Identity | `William Scott Davis II <billydeeii136@gmail.com>` | All commits |

**All 22 Repositories:**

```
wsd-warp-control (automation hub)
codex-wsd-control (Codex coordination)
wsd-cumseeme-live (jailed)
wsdenterprisesworldwide.com (apex domain)
wsdenterpirsesworldwidecloudservices.cloud (layer 2)
vokdesigngarage.com (layer 2)
neighborhoodcarspa.us.com (layer 2)
lebeautiful-botanicals.us.com (layer 2)
acwyatt.com (layer 2)
Cloudflare (WSD_CCOS)
wsd-warp-ai-orchestrator (AI orchestration)
Codex (Codex project)
warp (Warp project)
wsd-master-credential-vault (secrets)
cloud-native-store (cloud storage)
wsd-ccos-warp-platform (WARP platform)
free-1000-tb-cloud-cluster-mesh (cluster mesh)
vokdesigngarage-com-private-proof-hardening (hardening)
wsdenterpirsesworldwidecloudservices.cloud- (variant)
cumseeme.live (jailed domain)
lebeautiful-enterprise (enterprise)
creator-platform-backend (backend)
```

---

## 8. Domain & DNS Architecture

### 7-Domain Pyramid (Porkbun → Cloudflare)

| Layer | Domain | Status | Repo | Notes |
|---|---|---|---|---|
| **Apex (Layer 1)** | `wsdenterprisesworldwide.com` | Active | `wsdenterprisesworldwide.com` | Master domain |
| Layer 2 | `wsdenterpirsesworldwidecloudservices.cloud` | Active | `wsdenterpirsesworldwidecloudservices.cloud` | Cloud services |
| Layer 2 | `lebeautiful-botanicals.us.com` | Active | `lebeautiful-botanicals.us.com` | Beauty brand |
| Layer 2 | `acwyatt.com` | Active | `acwyatt.com` | Trucking |
| Layer 2 | `neighborhoodcarspa.us.com` | Active | `neighborhoodcarspa.us.com` | Car spa |
| Layer 2 | `vokdesigngarage.com` | Active | `vokdesigngarage.com` | Design |
| **Jailed** | `cumseeme.live` | Isolated | `wsd-cumseeme-live` | Adult platform — NEVER intersects |

**DNS Resolution:**
- `wsdenterprisesworldwide.com` → `104.21.58.43`, `172.67.200.53` (Cloudflare)
- All domains: Porkbun registrar → Cloudflare DNS → Cloudflare proxy

---

## 9. Network & Connectivity

### Interfaces

| Interface | Status | Type | Notes |
|---|---|---|---|
| `lo0` | UP | Loopback | Localhost |
| `en0` | UP | Wi-Fi (primary) | Wireless |
| `en1` | UP | Wi-Fi (secondary) | Promiscuous mode |
| `bridge0` | UP | Bridge | Virtual |
| `p2p0` | UP | Peer-to-peer | Wi-Fi Direct |
| `awdl0` | UP | Apple Wireless Direct Link | AirDrop |
| `utun0-3` | UP | Tunnel interfaces | VPN/WARP |

### Network State

| Property | Value | Notes |
|---|---|---|
| Default Gateway | `10.0.0.1` | Home router |
| DNS Servers | `127.0.2.2`, `127.0.2.3` | Local DNS (WARP/Cloudflare) |
| Active Connections | 11 | Established TCP |
| Listening Ports | `*:2968`, `localhost:3000`, `localhost:9277` | Local services |
| Cloudflared | RUNNING | Tunnel daemon active |
| Google Drive | OFF | Desktop app not running (symlinks still work) |
| Dropbox | OFF | Not active |

---

## 10. Automation & Scheduling

### Cron Jobs (User `billydeeii136`)

| Schedule | Script | Purpose | Log | Next Run |
|---|---|---|---|---|
| `*/10 * * * *` | `WSD_CROSS_SYSTEM_COORDINATOR.sh` | Sync all systems, GitHub push, health checks | `~/logs/coordinator_cron.log` | Continuous |
| `0 * * * *` | `WSD_GOOGLE_DRIVE_OFFLOADER.sh` | Auto-offload files to Google Drive | `~/logs/offloader_cron.log` | Every hour |
| `0 9 * * *` | `wsd_mac_ultimate_optimizer.sh` | Browser/system optimization | `~/logs/optimizer_cron.log` | Daily 9AM |

### User LaunchAgents (8)

| Agent | Purpose | Status | Notes |
|---|---|---|---|
| `WSD_DISABLED_20260604T211321Z` | Disabled agent | Inactive | Old — should be removed |
| `com.epson.epsvcp.plist` | Epson printer | Active | Vendor software |
| `com.google.GoogleUpdater.wake.plist` | Google Chrome updater | Active | Wake for updates |
| `com.google.keystone.agent.plist` | Google Keystone | Active | Chrome auto-update |
| `com.google.keystone.xpcservice.plist` | Google Keystone XPC | Active | Chrome auto-update |
| `com.wsd.cloud-login-automation.plist` | WSD automation | Active | Custom — your script |
| `com.wsd.downloadmac-drain.plist` | WSD download drain | Active | Custom — your script |
| `com.wsd.dropbox-sync-guard.plist` | WSD Dropbox guard | Active | Custom — your script |
| `live.cumseeme.site.plist` | Cumseeme site | Active | ⚠️ Jailed domain agent |

**System LaunchAgents (7):** All Epson printer-related (non-critical)

**System LaunchDaemons (4):**

| Daemon | Purpose | Status |
|---|---|---|
| `com.cloudflare.1dot1dot1dot1.macos.warp.daemon` | WARP VPN | Active |
| `com.cloudflare.cloudflared` | Cloudflare Tunnel | Active |
| `com.epson.RemotePrintIODaemon` | Epson remote print | Active |
| `com.epson.ijfax.FaxIODaemon` | Epson fax | Active |

### WARP Agent Lanes (33)

```
MANIFEST.tsv, README.md, alibaba, aws, azure, chatgpt, claude, cline,
cloudflare, codex, copilot, cursor, digitalocean, github, google, hetzner,
ibm, intake, kubernetes, linode, logs, oracle, ovh, programs, pulumi,
qodo, qwen, scaleway, shared-brain, supermaven, terminal, tmp, vultr, warp
```

---

## 11. Process & Resource State

### Top CPU Consumers (Real-time)

| PID | Process | CPU % | Notes |
|---|---|---|---|
| 2726 | `stable` (WARP) | 54.7% | ⚠️ **Critical** — WARP using >50% CPU |
| 55708 | `containermanager` | 31.9% | System container management |
| 73362 | `WindowServer` | 22.5% | macOS graphics compositor |
| 55646 | `deleted` | 21.9% | Unknown process — needs investigation |
| 59628 | `FolderActionsDis` | 14.4% | Folder action dispatcher |

### Top Memory Consumers

| PID | Process | Memory % | Notes |
|---|---|---|---|
| 2726 | `stable` (WARP) | 11.4% | ⚠️ WARP using 11% of 4GB RAM |
| 73362 | `WindowServer` | 0.5% | Normal |
| 55889 | `Notes` | 0.8% | Apple Notes app |
| 54356 | `cloudd` | 0.5% | iCloud daemon |
| 34762 | `Finder` | 0.3% | Normal |

**⚠️ CRITICAL:** WARP (`stable` process) is consuming 54.7% CPU and 11.4% RAM on a 4GB MacBook Air. This is unsustainable. The process is the WARP terminal application itself (not a cloud agent), which suggests the app is in a heavy computation loop or the agent conversation is very long.

---

## 12. Security & Compliance

| Control | Status | Value | Notes |
|---|---|---|---|
| System Integrity Protection (SIP) | ✅ Enabled | `csrutil` | Kernel-level protection |
| Gatekeeper | ✅ Enabled | `assessments enabled` | App verification |
| Firewall | ✅ Enabled | `State = 1` | Application firewall |
| FileVault | ❌ Off | `fdesetup` | Disk encryption disabled |
| XProtect | ✅ Active | `XProtectPlistConfigData` | Malware signatures |
| SSH Key | ✅ Present | `id_ed25519` | Ed25519 key pair |
| SSH Config | ✅ Present | `~/.ssh/config` | Custom SSH configurations |
| Keychain | ✅ Active | `login.keychain-db`, `System.keychain` | Credential storage |

**⚠️ Risk:** FileVault is OFF. If the MacBook is lost or stolen, all data on the drive is accessible without a password. This is a significant risk for a system with 8 API tokens, SSH keys, and password managers.

---

## 13. CLI Tool Inventory

| Tool | Version | Primary Use | Status |
|---|---|---|---|
| Bash | 5.3.12 | Shell, scripts | ✅ Active |
| zsh | 5.8.1 | Fallback shell | ⚠️ Present but locked out |
| Git | 2.54.0 | Version control | ✅ Active |
| Node.js | 24.13.0 | JavaScript runtime | ✅ Active |
| npm | 11.16.0 | Package manager | ✅ Active |
| Python 3 | 3.13.7 | Python runtime | ✅ Active |
| pip3 | 25.2 | Python packages | ✅ Active |
| Homebrew | 5.1.15 | Package manager | ✅ Active |
| Ruby | 2.6.10 | Legacy runtime | ⚠️ Old version |
| rclone | 1.73.3 | Cloud sync | ✅ Active |
| Wrangler | 4.98.0 | Cloudflare Workers | ✅ Active |
| GitHub CLI | 2.93.0 | GitHub operations | ✅ Active |
| gcloud | 570.0.0 | Google Cloud | ✅ Active |
| cloudflared | 2026.5.2 | Cloudflare tunnels | ✅ Active |
| Docker | 29.5.3 | Containers | ✅ Installed |
| Terraform | 1.5.7 | Infrastructure | ✅ Active |
| Ansible | Not installed | Automation | ❌ Not installed |
| bc | Present | Calculator | ✅ Active |
| vm_stat | Present | Memory stats | ✅ Active |

---

## 14. Risk Assessment Matrix

| Risk | Severity | Likelihood | Impact | Mitigation | Status |
|---|---|---|---|---|---|
| WARP CPU hog (54.7%) | 🔴 High | Active | System slowdown, battery drain | Investigate WARP process | ⚠️ Ongoing |
| 4GB RAM constraint | 🔴 High | Constant | OOM, swapping, app crashes | Offload, reduce extensions, close unused apps | 🟡 Partial |
| `/System/Volumes/Data` at 96% | 🔴 High | Constant | System instability, update failures | Aggressive cleanup, cloud offload | 🟡 Partial |
| FileVault OFF | 🔴 High | Low (physical security) | Data theft if device stolen | Enable FileVault | ❌ Not mitigated |
| 8 API tokens in env | 🟡 Medium | Low | Token leakage if env logged | Never log env values, rotate regularly | 🟡 Partial |
| 65 VS Code extensions | 🟡 Medium | Constant | Slow startup, conflicts, memory | Audit and remove unused | 🟡 Partial |
| 10+ AI coding extensions | 🟡 Medium | Constant | Conflicting suggestions, API key conflicts | Limit to 5 active | 🟡 Partial |
| Google Drive sync OFF | 🟡 Medium | Ongoing | Stale cloud data, sync failures | Restart Google Drive app | ❌ Not mitigated |
| `deleted` process at 21.9% CPU | 🟡 Medium | Unknown | Unknown resource drain | Identify and terminate | ❌ Not investigated |
| 3 Cloudflare tunnels | 🟢 Low | Constant | Secure but adds latency | Normal operation | ✅ Mitigated |
| 22 GitHub repos | 🟢 Low | Constant | Management overhead | Automated sync | ✅ Mitigated |
| Epson printer daemons | 🟢 Low | Constant | Minor resource use | Non-critical | ✅ Acceptable |
| `cumseeme.live` agent | 🟢 Low | Contained | Jailed from other systems | Isolation enforced | ✅ Mitigated |

---

## 15. Dependency Graph (Simplified)

```
┌─────────────────────────────────────────────────────────────┐
│                        macOS 12.7.6                          │
│                     (4GB RAM, 4-core MBA)                      │
├─────────────────────────────────────────────────────────────┤
│  Shell Layer                                                 │
│  ├── /bin/bash (locked) ──→ All scripts, cron, terminal      │
│  └── zsh (secondary, unused)                                │
├─────────────────────────────────────────────────────────────┤
│  Application Layer                                           │
│  ├── Browsers (Chrome, Firefox, Safari, Opera, DDG)        │
│  ├── VS Code (65 extensions, 2.8GB) ──→ Bash terminal      │
│  ├── 1Password / Bitwarden ──→ Browser extensions          │
│  ├── WARP (54.7% CPU ──→ ⚠️ Critical)                      │
│  ├── Google Drive (sync OFF ──→ ⚠️ Needs restart)          │
│  └── Cloudflare WARP / cloudflared (3 tunnels)              │
├─────────────────────────────────────────────────────────────┤
│  CLI Tool Layer                                              │
│  ├── Git ──→ GitHub (22 repos)                              │
│  ├── Wrangler ──→ Cloudflare (Workers, KV, D1, Tunnels)     │
│  ├── gcloud ──→ GCP (BigQuery, AI Platform, etc.)           │
│  ├── rclone ──→ Google Drive (offload)                      │
│  ├── Docker ──→ Containers (not actively used)              │
│  └── Terraform ──→ Infrastructure (not actively used)     │
├─────────────────────────────────────────────────────────────┤
│  Credential Layer                                            │
│  ├── macOS Keychain (login, System)                         │
│  ├── 1Password app ──→ Browser extensions                    │
│  ├── Bitwarden app ──→ Browser extensions                  │
│  ├── SSH keys (~/.ssh/id_ed25519)                           │
│  └── Environment vars (8 tokens, names only logged)        │
├─────────────────────────────────────────────────────────────┤
│  Automation Layer                                            │
│  ├── Cron (3 jobs) ──→ Coordinator, Offloader, Optimizer     │
│  ├── LaunchAgents (8) ──→ WSD, Google, Epson, cumseeme    │
│  └── LaunchDaemons (4) ──→ WARP, cloudflared, Epson       │
├─────────────────────────────────────────────────────────────┤
│  Network Layer                                               │
│  ├── Wi-Fi (en0) ──→ 10.0.0.1 gateway                       │
│  ├── Cloudflare WARP ──→ 1.1.1.1 DNS, secure tunnel        │
│  ├── 3 Tunnels ──→ wsd-ccos-tunnel, MAC, my-ssh-tunnel    │
│  └── Google Drive (sync OFF, symlinks active)              │
├─────────────────────────────────────────────────────────────┤
│  Cloud Layer                                                 │
│  ├── Cloudflare ──→ 7 domains, Workers, KV, D1, Tunnels    │
│  ├── GitHub ──→ 22 private repos, auto-sync                │
│  ├── Google Drive ──→ 3 mounts, 8 offload lanes           │
│  └── GCP ──→ wsd-ccos-nexgen-1, 10+ services              │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer (7-Domain Pyramid)                            │
│  ├── Apex: wsdenterprisesworldwide.com                     │
│  ├── Layer 2: lebeautiful, acwyatt, vokdesigngarage,      │
│  │           neighborhoodcarspa, wsdcloudservices          │
│  └── Jailed: cumseeme.live (NEVER intersects)               │
└─────────────────────────────────────────────────────────────┘
```

---

## 16. Recommendations for Team Review

### Immediate (24-48 hours)

1. **Investigate WARP CPU usage** — `stable` process at 54.7% is unsustainable on 4GB RAM. Close WARP, restart, or check for agent conversation bloat.
2. **Identify `deleted` process** — PID 55646 at 21.9% CPU with name "deleted" is suspicious. Check with `ps -p 55646 -o command` and `lsof -p 55646`.
3. **Restart Google Drive** — Desktop sync app is OFF but symlinks still work. Restart to ensure bidirectional sync resumes.
4. **Enable FileVault** — `fdesetup enable` requires admin password. Protects all data if device is lost.

### Short-term (1 week)

5. **Audit VS Code extensions** — Remove unused AI extensions to reduce conflicts. Keep only 5 active AI coding assistants.
6. **Clean VS Code extension cache** — 508MB `CachedExtensionVSIXs` can be purged if disk pressure returns.
7. **Remove old LaunchAgents** — `WSD_DISABLED_20260604T211321Z` is a disabled folder that should be cleaned up.
8. **Review Google Chrome updater** — 3 Google agents (keystone, updater) run persistently. Consider if Chrome auto-update is necessary.

### Medium-term (1 month)

9. **Upgrade RAM or migrate workloads** — 4GB is insufficient for 65 VS Code extensions + 10+ AI tools + WARP + browsers + Docker. Consider cloud development environments or a machine with 16GB+ RAM.
10. **Implement Tier 2 gatekeeping** — File prefix enforcement, extension limits, cron governance, disk pressure gates.
11. **Credential rotation** — The 8 env tokens have unknown ages. Rotate oldest tokens (WSD_CLOUDFLARE_API_TOKEN, WSD_GITHUB_TOKEN, WSD_OPENAI_API_KEY) if not recently rotated.
12. **Consolidate AI tools** — 10+ AI coding assistants in VS Code is excessive. Choose 3-5 primary tools and disable others.

### Long-term (3 months)

13. **Deploy WSD Federated Governance Charter** — Formalize the voting system, proposal mechanism, and emergency override process.
14. **Cloud development environment** — Move heavy workloads (Docker, multiple AI agents, large builds) to Cloudflare Workers or GCP VMs to reduce local resource pressure.
15. **Automated compliance checks** — Daily audit report generation, automated alerting on policy violations, self-healing remediation.

---

## 17. Team Review Checklist

- [ ] **WARP** — Review WARP CPU usage recommendation. Confirm or reject.
- [ ] **Codex** — Review VS Code extension limit (5 AI assistants). Confirm or propose alternative.
- [ ] **Terminal** — Review shell lock and script prefix enforcement. Confirm.
- [ ] **VS Code** — Review extension cache limit (400MB) and auto-clean. Confirm or adjust.
- [ ] **GitHub** — Review repo privacy and commit frequency. Confirm.
- [ ] **Cloudflare** — Review tunnel count and cost limits. Confirm.
- [ ] **Google Drive** — Review lane structure and auto-offload rules. Confirm or adjust.
- [ ] **Security** — Review FileVault recommendation and credential rotation policy. Confirm or defer.

---

*This report is auto-generated by `WSD_UNIVERSAL_BASELINE_AUDIT.sh` and committed to `billydeeii136/wsd-warp-control`. Updated versions will be generated on each audit run.*

**Co-Authored-By:** Oz <oz-agent@warp.dev>
