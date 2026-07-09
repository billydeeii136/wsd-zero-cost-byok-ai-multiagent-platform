# WSD Automated Daily Maintenance Schedule
**Owner:** William Scott Davis II
**Generated:** 2026-06-07T07:21:00Z
**Source:** `billydeeii136/wsd-warp-control` — `docs/SYSTEM_AUTOMATION_STATUS.md`

---

## Cron Job Summary

All cron jobs are installed under the user `billydeeii136` (`crontab -l`).

| # | Script | Schedule | Cron Expression | Purpose |
|---|---|---|---|---|
| 1 | `WSD_CROSS_SYSTEM_COORDINATOR.sh` | Every 10 minutes | `*/10 * * * *` | Cross-lane sync, GitHub push, VS Code health, browser monitoring, disk alerts |
| 2 | `WSD_GOOGLE_DRIVE_OFFLOADER.sh` | Every hour | `0 * * * *` | Automated offload to Google Drive 04_DOWNLOADS/AUTO_OFFLOAD |
| 3 | `WSD_DAILY_HEALTH_CHECK.sh` | Daily at 9:00 AM | `0 9 * * *` | System diagnostics, disk cleanup, app verification, browser health, security audit, health score |

---

## Script Details

### 1. WSD_CROSS_SYSTEM_COORDINATOR.sh
- **Location:** `~/WSD_CROSS_SYSTEM_COORDINATOR.sh` (also in `wsd-warp-control/scripts/`)
- **Log:** `~/logs/coordinator_$(date +%Y%m%d_%H%M%S).log` and `~/logs/coordinator_cron.log`
- **What it does:**
  - Verifies system state (bash, VS Code, 1Password, Bitwarden, GitHub CLI, Wrangler, rclone)
  - Runs daily optimizer at 9:00 AM
  - Runs hourly offloader
  - Syncs all repos to GitHub (`wsd-warp-control`, `codex-wsd-control`, `wsd-warp-ai-orchestrator`)
  - Checks VS Code extension health
  - Monitors browser processes (CPU, memory)
  - Triggers disk alerts at 75% and 85% usage
- **Integrates with:** Codex, WARP, Terminal, VS Code, GitHub, Cloudflare, Google Drive

### 2. WSD_GOOGLE_DRIVE_OFFLOADER.sh
- **Location:** `~/WSD_GOOGLE_DRIVE_OFFLOADER.sh` (also in `wsd-warp-control/scripts/`)
- **Log:** `~/logs/gdrive_offloader_$(date +%Y%m%d_%H%M%S).log` and `~/logs/offloader_cron.log`
- **What it does:**
  - Moves Downloads files older than 1 hour to Google Drive `04_DOWNLOADS/AUTO_OFFLOAD/01_Downloads_Hourly`
  - Moves large files (>50MB) immediately to `02_Large_Files`
  - Moves installers (.dmg, .pkg, .exe, .zip) to `03_Installers_DMG`
  - Moves media (.jpg, .png, .mp4, .mov) to `04_Images_Media`
  - Moves archives (.zip, .tar.gz) to `05_Archive_ZIP`
  - Moves old .sh scripts to `06_Scripts_Terminal`
  - Backs up VS Code workspaces to `07_VSCode_Workspaces`
  - Cleans VS Code workspaceStorage (>30 days), backups (>7 days), cache (>7 days)
- **Google Drive target:** `My Drive/04_DOWNLOADS/AUTO_OFFLOAD/`

### 3. WSD_DAILY_HEALTH_CHECK.sh
- **Location:** `~/WSD_DAILY_HEALTH_CHECK.sh` (also in `wsd-warp-control/scripts/`)
- **Log:** `~/logs/health_check_$(date +%Y%m%d_%H%M%S).log` and `~/logs/health_cron.log`
- **Report:** `~/logs/reports/health_check_$(date +%Y%m%d_%H%M%S).md`
- **What it does:**
  - System diagnostics: CPU, memory, disk, battery, load average, temperature
  - Disk cleanup & recovery: caches, logs, Trash, temp, browser caches, old downloads to Google Drive
  - Application verification: broken permissions, empty apps, duplicate bundle IDs (bash 3.2 compatible)
  - Browser health check: Chrome, Safari, Firefox, Opera, DuckDuckGo with version detection
  - Startup & background audit: login items, LaunchAgents, top processes by CPU
  - Google Drive offload verification: 8 lane sizes
  - Security & config audit: FileVault, firewall, SIP, SSH
  - GitHub project status: wsd-warp-control, codex-wsd-control sync
  - Health score (0-100) with threshold-based alerts
- **Runs:** Once daily at 9:00 AM local time
- **Bash 3.2 compatible:** No associative arrays, no subshell pipe writes for report

---

## Execution Log Locations

```
~/logs/
├── coordinator_YYYYMMDD_HHMMSS.log       (per-run coordinator log)
├── coordinator_cron.log                  (cron stderr/stdout aggregate)
├── gdrive_offloader_YYYYMMDD_HHMMSS.log  (per-run offloader log)
├── offloader_cron.log                    (cron stderr/stdout aggregate)
├── health_check_YYYYMMDD_HHMMSS.log      (per-run health check log)
├── health_cron.log                       (cron stderr/stdout aggregate)
├── reports/                              (markdown reports)
│   └── health_check_YYYYMMDD_HHMMSS.md
└── launchagents_audit.txt                (startup agent audit output)
```

---

## GitHub Repositories Auto-Synced

| Repo | Branch | Purpose |
|---|---|---|
| `billydeeii136/wsd-warp-control` | `main` | WARP system scripts, automation, status docs |
| `billydeeii136/codex-wsd-control` | `main` | Codex coordination, WSD control layer |
| `billydeeii136/wsd-warp-ai-orchestrator` | `main` | AI orchestrator and lane configs |

All three repos receive auto-commits every 10 minutes from the coordinator.
Commit message format: `auto-coord: YYYYMMDD_HHMMSS sync-all-systems`

---

## Manual Override Commands

```bash
# Run any script manually
bash ~/WSD_DAILY_HEALTH_CHECK.sh
bash ~/WSD_GOOGLE_DRIVE_OFFLOADER.sh
bash ~/WSD_CROSS_SYSTEM_COORDINATOR.sh

# View cron jobs
crontab -l

# Edit cron jobs
crontab -e

# View latest logs
ls -lt ~/logs/ | head -10
tail -f ~/logs/coordinator_cron.log

# Check GitHub push status
cd ~/wsd-warp-control && git status
cd ~/codex-wsd-control && git status
```

---

## Isolation Boundaries

- `cumseeme.live` remains jailed off from all other systems
- No credential harvesting or vault consolidation performed
- All password management stays in native 1Password/Bitwarden/iCloud Keychain
- WARP scripts are private to `billydeeii136/wsd-warp-control`

---

*This schedule is maintained by the WSD Cross-System Coordinator. Changes are auto-committed to GitHub.*
