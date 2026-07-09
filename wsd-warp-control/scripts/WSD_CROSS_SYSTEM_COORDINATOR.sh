#!/bin/bash
# WSD_CROSS_SYSTEM_COORDINATOR.sh
# Multi-brain orchestration: runs all systems in concert
# Codex + WARP + Terminal + GitHub + VS Code + Cloudflare + all CLIs
# Runs every 10 minutes to keep all systems synced

set -uo pipefail

ROOT="${ROOT:-$HOME}"
LOG_DIR="$ROOT/logs"
LOG_FILE="$LOG_DIR/coordinator_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

log "======================================"
log "WSD CROSS-SYSTEM COORDINATOR"
log "Started: $(date)"
log "======================================"

# --- 1. Verify system state ---
log "--- SYSTEM STATE VERIFICATION ---"
BASH_VER=$(bash --version 2>/dev/null | head -1)
log "Shell: $BASH_VER"
log "Terminal: $(defaults read com.apple.Terminal Shell 2>/dev/null || echo "UNKNOWN")"
log "VS Code: $(ls /Applications/ | grep -i "Visual Studio Code" || echo "NOT_INSTALLED")"
log "1Password: $(ls /Applications/ | grep -i "1Password" || echo "NOT_INSTALLED")"
log "Bitwarden: $(ls /Applications/ | grep -i "Bitwarden" || echo "NOT_INSTALLED")"
log "GitHub CLI: $(gh --version 2>/dev/null | head -1 || echo "NOT_INSTALLED")"
log "Wrangler: $(wrangler --version 2>/dev/null || echo "NOT_INSTALLED")"
log "Rclone: $(rclone --version 2>/dev/null | head -1 || echo "NOT_INSTALLED")"

# --- 2. Run daily optimizer (if hour matches) ---
HOUR=$(date +%H)
if [ "$HOUR" = "09" ]; then
    log "--- RUNNING 9AM DAILY OPTIMIZER ---"
    if [ -f "$ROOT/wsd_mac_ultimate_optimizer.sh" ]; then
        bash "$ROOT/wsd_mac_ultimate_optimizer.sh" 2>/dev/null && log "Daily optimizer: OK" || log "Daily optimizer: FAILED"
    else
        log "Daily optimizer: NOT FOUND"
    fi
fi

# --- 3. Run hourly offloader ---
log "--- RUNNING HOURLY OFFLOADER ---"
if [ -f "$ROOT/WSD_GOOGLE_DRIVE_OFFLOADER.sh" ]; then
    bash "$ROOT/WSD_GOOGLE_DRIVE_OFFLOADER.sh" 2>/dev/null && log "Offloader: OK" || log "Offloader: FAILED"
else
    log "Offloader: NOT FOUND"
fi

# --- 4. GitHub sync all repos ---
log "--- GITHUB SYNC ALL REPOS ---"
for repo in "$ROOT/wsd-warp-control" "$ROOT/codex-wsd-control" "$ROOT/wsd-warp-ai-orchestrator"; do
    if [ -d "$repo/.git" ]; then
        cd "$repo"
        git add -A 2>/dev/null
        git commit -m "auto-coord: $(date +%Y%m%d_%H%M%S) sync-all-systems

Co-Authored-By: Oz <oz-agent@warp.dev>" 2>/dev/null
        git push origin main 2>/dev/null && log "GitHub: $(basename "$repo") synced" || log "GitHub: $(basename "$repo") no changes or push failed"
    fi
done

# --- 5. VS Code extension health check ---
log "--- VS CODE HEALTH ---"
VSCODE_EXTENSIONS="$ROOT/Library/Application Support/Code/extensions"
if [ -d "$VSCODE_EXTENSIONS" ]; then
    EXT_COUNT=$(ls -1 "$VSCODE_EXTENSIONS" 2>/dev/null | wc -l | tr -d ' ')
    log "VS Code: $EXT_COUNT extensions installed"
    # Check for large extensions
    LARGE_EXT=$(find "$VSCODE_EXTENSIONS" -maxdepth 1 -type d -exec du -sk {} + 2>/dev/null | sort -rn | head -5)
    log "VS Code: Top 5 largest extensions:"
    echo "$LARGE_EXT" | while read -r size name; do
        log "  $size KB - $(basename "$name")"
    done
fi

# --- 6. Browser process check ---
log "--- BROWSER PROCESSES ---"
for browser in "Google Chrome" "Firefox" "Safari" "Opera" "DuckDuckGo"; do
    PID=$(pgrep -x "$browser" 2>/dev/null | head -1)
    if [ -n "$PID" ]; then
        CPU=$(ps -p "$PID" -o %cpu= 2>/dev/null | tr -d ' ')
        MEM=$(ps -p "$PID" -o %mem= 2>/dev/null | tr -d ' ')
        log "$browser: PID=$PID CPU=${CPU}% MEM=${MEM}%"
    else
        log "$browser: NOT RUNNING"
    fi
done

# --- 7. Disk alert ---
DF_PCT=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
if [ "$DF_PCT" -gt 85 ]; then
    log "ALERT: Disk usage critical at ${DF_PCT}%"
    osascript -e 'display notification "Disk usage critical: '"$DF_PCT"'%" with title "WSD System Alert"' 2>/dev/null || true
elif [ "$DF_PCT" -gt 75 ]; then
    log "WARNING: Disk usage high at ${DF_PCT}%"
fi

# --- 8. Summary ---
log "======================================"
log "COORDINATOR COMPLETE"
log "Finished: $(date)"
log "Log: $LOG_FILE"
log "======================================"
