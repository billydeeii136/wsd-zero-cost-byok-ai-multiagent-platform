#!/bin/bash
# WSD_DAILY_HEALTH_CHECK.sh
# Comprehensive daily MacBook Air health check, cleanup, and application verification
# Runs: system diagnostics, disk recovery, app verification, browser health, log rotation
# Scheduled: 0 9 * * * (daily 9:00 AM)
# Author: Oz / WSD Systems

set -uo pipefail

# ============================
# CONFIGURATION
# ============================
USER_HOME="$HOME"
LOG_DIR="$USER_HOME/logs"
GDRIVE_BASE="$USER_HOME/Library/CloudStorage"
GDRIVE_DIR="$USER_HOME/Library/CloudStorage/GoogleDrive-williamscottdavis136@gmail.com/My Drive/04_DOWNLOADS/AUTO_OFFLOAD"
REPORT_DIR="$USER_HOME/logs/reports"
REPORT_FILE="$REPORT_DIR/health_check_$(date +%Y%m%d_%H%M%S).md"
LOG_FILE="$LOG_DIR/health_check_$(date +%Y%m%d_%H%M%S).log"
CLEANUP_LOG="$LOG_DIR/cleanup_$(date +%Y%m%d_%H%M%S).log"
APP_VERIFICATION_LOG="$LOG_DIR/app_verify_$(date +%Y%m%d_%H%M%S).log"
DISK_THRESHOLD_WARN=70
DISK_THRESHOLD_CRIT=80
TEMP_THRESHOLD=80
CPU_THRESHOLD_WARN=70
MEM_THRESHOLD_WARN=80
HEALTH_SCORE=100

mkdir -p "$LOG_DIR" "$REPORT_DIR" "$GDRIVE_DIR"

exec > >(tee -a "$LOG_FILE")
exec 2>&1

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
report() { echo "$*" >> "$REPORT_FILE"; }

log "======================================"
log "WSD DAILY HEALTH CHECK"
log "Started: $(date)"
log "Log: $LOG_FILE"
log "Report: $REPORT_FILE"
log "======================================"

report "# WSD Daily Health Check Report"
report ""
report "Date: $(date)"
report "Host: $(hostname)"
report "---"

# ============================
# 1. SYSTEM DIAGNOSTICS
# ============================
log ""
log "--- 1. SYSTEM DIAGNOSTICS ---"
report "## 1. System Diagnostics"
report ""

UPTIME=$(uptime | awk '{print $3,$4}' | sed 's/,//')
OS_VERSION=$(sw_vers -productVersion 2>/dev/null)
OS_BUILD=$(sw_vers -buildVersion 2>/dev/null)
report "- **OS**: macOS $OS_VERSION ($OS_BUILD)"
report "- **Uptime**: $UPTIME"

# CPU usage
CPU_IDLE=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $7}' | sed 's/%//' | head -1)
CPU_USAGE=$(echo "100 - ${CPU_IDLE:-0}" | bc -l 2>/dev/null || echo "N/A")
log "CPU Usage: ${CPU_USAGE}%"
report "- **CPU Usage**: ${CPU_USAGE}%"
if [ "$CPU_USAGE" != "N/A" ] && [ "$(echo "$CPU_USAGE >= $CPU_THRESHOLD_WARN" | bc -l 2>/dev/null)" = "1" ]; then
    log "WARNING: CPU usage above ${CPU_THRESHOLD_WARN}%"
    HEALTH_SCORE=$((HEALTH_SCORE - 10))
    report "- ⚠️ CPU usage high"
fi

# Memory
MEM_INFO=$(vm_stat 2>/dev/null)
if [ -n "$MEM_INFO" ]; then
    PAGE_SIZE=$(vm_stat | grep "page size of" | awk '{print $8}' | sed 's/\.//')
    [ -z "$PAGE_SIZE" ] && PAGE_SIZE=4096
    FREE_PAGES=$(echo "$MEM_INFO" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    INACTIVE_PAGES=$(echo "$MEM_INFO" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    ACTIVE_PAGES=$(echo "$MEM_INFO" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    WIRED_PAGES=$(echo "$MEM_INFO" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
    [ -z "$FREE_PAGES" ] && FREE_PAGES=0
    [ -z "$INACTIVE_PAGES" ] && INACTIVE_PAGES=0
    [ -z "$ACTIVE_PAGES" ] && ACTIVE_PAGES=0
    [ -z "$WIRED_PAGES" ] && WIRED_PAGES=0
    FREE_MB=$(echo "($FREE_PAGES + $INACTIVE_PAGES) * $PAGE_SIZE / 1024 / 1024" | bc -l 2>/dev/null | awk '{printf "%d", $1}')
    USED_MB=$(echo "($ACTIVE_PAGES + $WIRED_PAGES) * $PAGE_SIZE / 1024 / 1024" | bc -l 2>/dev/null | awk '{printf "%d", $1}')
    TOTAL_MB=$(echo "$FREE_MB + $USED_MB" | bc -l 2>/dev/null | awk '{printf "%d", $1}')
    if [ "$TOTAL_MB" -gt 0 ] 2>/dev/null; then
        MEM_USAGE_PCT=$(echo "scale=1; $USED_MB * 100 / $TOTAL_MB" | bc -l 2>/dev/null)
        log "Memory: ${USED_MB}MB / ${TOTAL_MB}MB (${MEM_USAGE_PCT}%)"
        report "- **Memory**: ${USED_MB}MB / ${TOTAL_MB}MB (${MEM_USAGE_PCT}%)"
        if [ "$(echo "$MEM_USAGE_PCT >= $MEM_THRESHOLD_WARN" | bc -l 2>/dev/null)" = "1" ]; then
            log "WARNING: Memory usage above ${MEM_THRESHOLD_WARN}%"
            HEALTH_SCORE=$((HEALTH_SCORE - 10))
            report "- ⚠️ Memory usage high"
        fi
    fi
fi

# Disk
DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
DISK_USED=$(df -h / | awk 'NR==2{print $3}')
DISK_AVAIL=$(df -h / | awk 'NR==2{print $4}')
DISK_PCT=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
log "Disk: $DISK_USED / $DISK_TOTAL used ($DISK_PCT%), $DISK_AVAIL available"
report "- **Disk**: $DISK_USED / $DISK_TOTAL used ($DISK_PCT%), $DISK_AVAIL available"
if [ "$DISK_PCT" -ge "$DISK_THRESHOLD_CRIT" ] 2>/dev/null; then
    log "CRITICAL: Disk usage above ${DISK_THRESHOLD_CRIT}%"
    HEALTH_SCORE=$((HEALTH_SCORE - 20))
    report "- 🔴 Disk usage CRITICAL"
elif [ "$DISK_PCT" -ge "$DISK_THRESHOLD_WARN" ] 2>/dev/null; then
    log "WARNING: Disk usage above ${DISK_THRESHOLD_WARN}%"
    HEALTH_SCORE=$((HEALTH_SCORE - 10))
    report "- ⚠️ Disk usage high"
fi

# Temperature (if available)
if command -v istats >/dev/null 2>&1; then
    TEMP=$(istats cpu temp --value-only 2>/dev/null | sed 's/°C//')
    log "CPU Temperature: ${TEMP}°C"
    report "- **CPU Temperature**: ${TEMP}°C"
    if [ -n "$TEMP" ] && [ "$(echo "$TEMP >= $TEMP_THRESHOLD" | bc -l 2>/dev/null)" = "1" ]; then
        log "WARNING: CPU temperature above ${TEMP_THRESHOLD}°C"
        HEALTH_SCORE=$((HEALTH_SCORE - 10))
        report "- ⚠️ CPU temperature high"
    fi
else
    log "CPU Temperature: istats not installed"
    report "- **CPU Temperature**: N/A (istats not installed)"
fi

# Battery (if available)
if command -v pmset >/dev/null 2>&1; then
    BATTERY_PCT=$(pmset -g batt | grep -Eo "[0-9]+%" | head -1 | sed 's/%//')
    BATTERY_STATE=$(pmset -g batt | grep "Now drawing from" | sed 's/.*Now drawing from \(.*\)/\1/' | head -1)
    log "Battery: ${BATTERY_PCT}% — $BATTERY_STATE"
    report "- **Battery**: ${BATTERY_PCT}% — $BATTERY_STATE"
else
    log "Battery: pmset not available"
    report "- **Battery**: N/A"
fi

# Load average
LOAD_AVG=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')
log "Load Average (1m): $LOAD_AVG"
report "- **Load Average**: $LOAD_AVG"

# ============================
# 2. DISK CLEANUP & RECOVERY
# ============================
log ""
log "--- 2. DISK CLEANUP & RECOVERY ---"
report ""
report "## 2. Disk Cleanup & Recovery"
report ""

FREE_BEFORE=$(df -k / | awk 'NR==2{print $4}')
SPACE_RECOVERED=0

# 2.1 User caches older than 30 days
CACHE_SIZE_BEFORE=$(du -sk "$USER_HOME/Library/Caches" 2>/dev/null | awk '{print $1}')
find "$USER_HOME/Library/Caches" -type f -mtime +30 -delete 2>/dev/null
find "$USER_HOME/Library/Caches" -type d -empty -delete 2>/dev/null
CACHE_SIZE_AFTER=$(du -sk "$USER_HOME/Library/Caches" 2>/dev/null | awk '{print $1}')
CACHE_FREED=$((CACHE_SIZE_BEFORE - CACHE_SIZE_AFTER))
log "Caches: freed ${CACHE_FREED}KB (before: ${CACHE_SIZE_BEFORE}KB, after: ${CACHE_SIZE_AFTER}KB)"
report "- Caches freed: ${CACHE_FREED}KB"
SPACE_RECOVERED=$((SPACE_RECOVERED + CACHE_FREED))

# 2.2 User logs older than 60 days
LOG_SIZE_BEFORE=$(du -sk "$USER_HOME/Library/Logs" 2>/dev/null | awk '{print $1}')
find "$USER_HOME/Library/Logs" -type f -mtime +60 -delete 2>/dev/null
LOG_SIZE_AFTER=$(du -sk "$USER_HOME/Library/Logs" 2>/dev/null | awk '{print $1}')
LOG_FREED=$((LOG_SIZE_BEFORE - LOG_SIZE_AFTER))
log "Logs: freed ${LOG_FREED}KB"
report "- Logs freed: ${LOG_FREED}KB"
SPACE_RECOVERED=$((SPACE_RECOVERED + LOG_FREED))

# 2.3 Trash items older than 30 days
TRASH_SIZE_BEFORE=$(du -sk "$USER_HOME/.Trash" 2>/dev/null | awk '{print $1}')
find "$USER_HOME/.Trash" -type f -mtime +30 -delete 2>/dev/null
find "$USER_HOME/.Trash" -type d -empty -delete 2>/dev/null
TRASH_SIZE_AFTER=$(du -sk "$USER_HOME/.Trash" 2>/dev/null | awk '{print $1}')
TRASH_FREED=$((TRASH_SIZE_BEFORE - TRASH_SIZE_AFTER))
log "Trash: freed ${TRASH_FREED}KB"
report "- Trash freed: ${TRASH_FREED}KB"
SPACE_RECOVERED=$((SPACE_RECOVERED + TRASH_FREED))

# 2.4 Temporary files
TMP_SIZE_BEFORE=$(du -sk /tmp 2>/dev/null | awk '{print $1}')
find /tmp -type f -user "$USER" -mtime +7 -delete 2>/dev/null
TMP_SIZE_AFTER=$(du -sk /tmp 2>/dev/null | awk '{print $1}')
TMP_FREED=$((TMP_SIZE_BEFORE - TMP_SIZE_AFTER))
log "Temp files: freed ${TMP_FREED}KB"
report "- Temp files freed: ${TMP_FREED}KB"
SPACE_RECOVERED=$((SPACE_RECOVERED + TMP_FREED))

# 2.5 Safari caches
SAFARI_CACHE_SIZE_BEFORE=$(du -sk "$USER_HOME/Library/Caches/com.apple.Safari" 2>/dev/null | awk '{print $1}')
find "$USER_HOME/Library/Caches/com.apple.Safari" -type f -mtime +14 -delete 2>/dev/null
SAFARI_CACHE_SIZE_AFTER=$(du -sk "$USER_HOME/Library/Caches/com.apple.Safari" 2>/dev/null | awk '{print $1}')
SAFARI_FREED=$((SAFARI_CACHE_SIZE_BEFORE - SAFARI_CACHE_SIZE_AFTER))
log "Safari caches: freed ${SAFARI_FREED}KB"
report "- Safari caches freed: ${SAFARI_FREED}KB"
SPACE_RECOVERED=$((SPACE_RECOVERED + SAFARI_FREED))

# 2.6 Chrome caches
CHROME_CACHE_SIZE_BEFORE=$(du -sk "$USER_HOME/Library/Caches/Google/Chrome" 2>/dev/null | awk '{print $1}')
find "$USER_HOME/Library/Caches/Google/Chrome" -type f -mtime +7 -delete 2>/dev/null
CHROME_CACHE_SIZE_AFTER=$(du -sk "$USER_HOME/Library/Caches/Google/Chrome" 2>/dev/null | awk '{print $1}')
CHROME_FREED=$((CHROME_CACHE_SIZE_BEFORE - CHROME_CACHE_SIZE_AFTER))
log "Chrome caches: freed ${CHROME_FREED}KB"
report "- Chrome caches freed: ${CHROME_FREED}KB"
SPACE_RECOVERED=$((SPACE_RECOVERED + CHROME_FREED))

# 2.7 Firefox caches
FF_CACHE_SIZE_BEFORE=$(du -sk "$USER_HOME/Library/Caches/Firefox" 2>/dev/null | awk '{print $1}')
find "$USER_HOME/Library/Caches/Firefox" -type f -mtime +7 -delete 2>/dev/null
FF_CACHE_SIZE_AFTER=$(du -sk "$USER_HOME/Library/Caches/Firefox" 2>/dev/null | awk '{print $1}')
FF_FREED=$((FF_CACHE_SIZE_BEFORE - FF_CACHE_SIZE_AFTER))
log "Firefox caches: freed ${FF_FREED}KB"
report "- Firefox caches freed: ${FF_FREED}KB"
SPACE_RECOVERED=$((SPACE_RECOVERED + FF_FREED))

# 2.8 Downloads cleanup — move old files (>7 days) to Google Drive
DOWNLOAD_OLD_SIZE=0
if [ -d "$USER_HOME/Downloads" ]; then
    find "$USER_HOME/Downloads" -maxdepth 1 -type f -mtime +7 -print0 2>/dev/null | while IFS= read -r -d '' file; do
        fname=$(basename "$file")
        mv -n "$file" "$GDRIVE_DIR/01_Downloads_Hourly/" 2>/dev/null && log "Moved old download to Google Drive: $fname" || log "Failed to move: $fname"
    done
fi

# 2.9 iOS DeviceSupport warning
IOS_SUPPORT="$USER_HOME/Library/Developer/Xcode/iOS DeviceSupport"
if [ -d "$IOS_SUPPORT" ]; then
    IOS_SIZE=$(du -sh "$IOS_SUPPORT" 2>/dev/null | awk '{print $1}')
    log "iOS DeviceSupport size: $IOS_SIZE"
    report "- iOS DeviceSupport: $IOS_SIZE (manual review needed if >1GB)"
fi

# 2.10 iTunes/Mobile backups
OLD_MOBILE_BACKUP="$USER_HOME/Library/Application Support/MobileSync/Backup"
if [ -d "$OLD_MOBILE_BACKUP" ]; then
    BACKUP_SIZE=$(du -sh "$OLD_MOBILE_BACKUP" 2>/dev/null | awk '{print $1}')
    log "iTunes/Mobile backups: $BACKUP_SIZE"
    report "- iTunes/Mobile backups: $BACKUP_SIZE"
fi

FREE_AFTER=$(df -k / | awk 'NR==2{print $4}')
ACTUAL_FREED=$((FREE_AFTER - FREE_BEFORE))
ACTUAL_FREED_MB=$(echo "scale=1; $ACTUAL_FREED / 1024" | bc -l 2>/dev/null || echo "$((ACTUAL_FREED / 1024))")
log "Total space recovered: ${SPACE_RECOVERED}KB (estimated), ${ACTUAL_FREED_MB}MB (actual df)"
report "- **Total space recovered**: ${ACTUAL_FREED_MB}MB"

# ============================
# 3. APPLICATION VERIFICATION
# ============================
log ""
log "--- 3. APPLICATION VERIFICATION ---"
report ""
report "## 3. Application Verification"
report ""

APPS_TOTAL=0
APPS_BROKEN=0
APPS_EMPTY=0
APPS_DUPLICATE=0
APPS_OK=0
APPS_BUNDLE_ISSUE=0
BROKEN_APPS=""
EMPTY_APPS=""
DUPLICATE_APPS=""

for app in /Applications/*.app; do
    if [ ! -d "$app" ]; then continue; fi
    APPS_TOTAL=$((APPS_TOTAL + 1))
    app_name=$(basename "$app")
    app_size=$(du -sk "$app" 2>/dev/null | awk '{print $1}')
    perms=$(stat -f "%Sp" "$app" 2>/dev/null)
    
    # Check broken permissions
    if [ "$perms" = "d---------" ]; then
        log "BROKEN: $app_name — $perms"
        APPS_BROKEN=$((APPS_BROKEN + 1))
        BROKEN_APPS="$BROKEN_APPS\n- $app_name"
        HEALTH_SCORE=$((HEALTH_SCORE - 5))
        continue
    fi
    
    # Check empty (<10KB)
    if [ "$app_size" -lt 10 ] 2>/dev/null; then
        log "EMPTY: $app_name — ${app_size}KB"
        APPS_EMPTY=$((APPS_EMPTY + 1))
        EMPTY_APPS="$EMPTY_APPS\n- $app_name"
        HEALTH_SCORE=$((HEALTH_SCORE - 3))
        continue
    fi
    
    # Check bundle ID
    info_plist=$(find "$app" -maxdepth 2 -name "Info.plist" 2>/dev/null | head -1)
    if [ -n "$info_plist" ]; then
        bundle_id=$(plutil -p "$info_plist" 2>/dev/null | grep CFBundleIdentifier | head -1 | awk -F'"' '{print $4}')
        if [ -z "$bundle_id" ]; then
            log "WARNING: $app_name — no bundle ID found"
            APPS_BUNDLE_ISSUE=$((APPS_BUNDLE_ISSUE + 1))
        fi
    else
        log "WARNING: $app_name — no Info.plist found"
        APPS_BUNDLE_ISSUE=$((APPS_BUNDLE_ISSUE + 1))
    fi
    
    APPS_OK=$((APPS_OK + 1))
done

# Check for duplicate apps by bundle ID (bash 3.2 compatible — no associative arrays)
BUNDLE_TMP="$LOG_DIR/bundle_check_$$.tmp"
> "$BUNDLE_TMP"
for app in /Applications/*.app; do
    if [ ! -d "$app" ]; then continue; fi
    app_name=$(basename "$app")
    info_plist=$(find "$app" -maxdepth 2 -name "Info.plist" 2>/dev/null | head -1)
    if [ -n "$info_plist" ]; then
        bundle_id=$(plutil -p "$info_plist" 2>/dev/null | grep CFBundleIdentifier | head -1 | awk -F'"' '{print $4}')
        if [ -n "$bundle_id" ]; then
            printf '%s\t%s\n' "$bundle_id" "$app_name" >> "$BUNDLE_TMP"
        fi
    fi
done

if [ -s "$BUNDLE_TMP" ]; then
    sort "$BUNDLE_TMP" | awk -F'\t' '
        {
            bid=$1; app=$2
            count[bid]++; apps[bid]=apps[bid] " " app
        }
        END {
            for (bid in count) {
                if (count[bid] > 1) {
                    printf "DUPLICATE: %s (%d) %s\n", bid, count[bid], apps[bid]
                }
            }
        }
    ' > "$BUNDLE_TMP.dupes"
    if [ -s "$BUNDLE_TMP.dupes" ]; then
        while IFS= read -r dup_line; do
            log "$dup_line"
            APPS_DUPLICATE=$((APPS_DUPLICATE + 1))
            DUPLICATE_APPS="$DUPLICATE_APPS\n- $dup_line"
            HEALTH_SCORE=$((HEALTH_SCORE - 5))
        done < "$BUNDLE_TMP.dupes"
    fi
fi
rm -f "$BUNDLE_TMP" "$BUNDLE_TMP.dupes"

log "App verification: $APPS_TOTAL total, $APPS_OK OK, $APPS_BROKEN broken, $APPS_EMPTY empty, $APPS_BUNDLE_ISSUE bundle issues, $APPS_DUPLICATE duplicate bundle IDs"
report "- Total apps: $APPS_TOTAL"
report "- OK: $APPS_OK"
report "- Broken: $APPS_BROKEN"
report "- Empty: $APPS_EMPTY"
report "- Bundle issues: $APPS_BUNDLE_ISSUE"
report "- Duplicate bundle IDs: $APPS_DUPLICATE"
[ -n "$BROKEN_APPS" ] && report "- **Broken apps**:$BROKEN_APPS"
[ -n "$EMPTY_APPS" ] && report "- **Empty apps**:$EMPTY_APPS"
[ -n "$DUPLICATE_APPS" ] && report "- **Duplicate bundle IDs**:$DUPLICATE_APPS"

# ============================
# 4. BROWSER HEALTH CHECK
# ============================
log ""
log "--- 4. BROWSER HEALTH CHECK ---"
report ""
report "## 4. Browser Health Check"
report ""

while IFS=: read -r app_file bundle_id; do
    app_name=$(echo "$app_file" | sed 's/\.app$//')
    app_path="/Applications/$app_file"
    # Check for numbered variants like Opera (1).app
    if [ ! -d "$app_path" ]; then
        alt_path=$(ls -d /Applications/"$app_name"*.app 2>/dev/null | head -1)
        if [ -n "$alt_path" ] && [ -d "$alt_path" ]; then
            app_path="$alt_path"
        fi
    fi
    if [ -d "$app_path" ]; then
        info_plist="$app_path/Contents/Info.plist"
        if [ -f "$info_plist" ]; then
            version=$(plutil -p "$info_plist" 2>/dev/null | grep CFBundleShortVersionString | head -1 | awk -F'"' '{print $4}')
            log "$app_name: installed ($version) at $app_path"
            report "- **$app_name**: $version ✅"
        else
            log "$app_name: installed but no Info.plist"
            report "- **$app_name**: installed (no version) ⚠️"
        fi
    else
        log "$app_name: not found in /Applications"
        report "- **$app_name**: not found ⚠️"
    fi
done <<'BROWSERLIST'
Google Chrome.app:com.google.Chrome
Safari.app:com.apple.Safari
Firefox.app:org.mozilla.firefox
Opera.app:com.operasoftware.Opera
DuckDuckGo.app:com.duckduckgo.macos.browser
BROWSERLIST

# Chrome cache size
CHROME_CACHE_TOTAL=$(du -sh "$USER_HOME/Library/Caches/Google/Chrome" 2>/dev/null | awk '{print $1}')
log "Chrome cache: $CHROME_CACHE_TOTAL"
report "- Chrome cache: $CHROME_CACHE_TOTAL"

# Firefox profile count
FF_PROFILE_COUNT=$(find "$USER_HOME/Library/Application Support/Firefox/Profiles" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
log "Firefox profiles: $FF_PROFILE_COUNT"
report "- Firefox profiles: $FF_PROFILE_COUNT"

# Safari website data size
SAFARI_DATA_SIZE=$(du -sh "$USER_HOME/Library/Safari/LocalStorage" 2>/dev/null | awk '{print $1}')
log "Safari LocalStorage: $SAFARI_DATA_SIZE"
report "- Safari LocalStorage: $SAFARI_DATA_SIZE"

# ============================
# 5. STARTUP & BACKGROUND AUDIT
# ============================
log ""
log "--- 5. STARTUP & BACKGROUND AUDIT ---"
report ""
report "## 5. Startup & Background Audit"
report ""

# Login items
LOGIN_ITEMS=$(osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null)
log "Login items: $LOGIN_ITEMS"
report "- Login items: $LOGIN_ITEMS"

# LaunchAgents
LAUNCH_AGENTS="$USER_HOME/Library/LaunchAgents"
AGENT_COUNT=0
if [ -d "$LAUNCH_AGENTS" ]; then
    AGENT_COUNT=$(ls -1 "$LAUNCH_AGENTS"/*.plist 2>/dev/null | wc -l | tr -d ' ')
    log "User LaunchAgents: $AGENT_COUNT"
    report "- User LaunchAgents: $AGENT_COUNT"
    ls -1 "$LAUNCH_AGENTS"/*.plist 2>/dev/null | while read agent; do
        agent_name=$(basename "$agent")
        report "  - $agent_name"
    done
else
    log "No user LaunchAgents directory"
    report "- User LaunchAgents: 0"
fi

# Running processes (top 10 by CPU)
log "Top 10 processes by CPU:"
ps -arcwww -o pid,comm,%cpu,mem -n 10 2>/dev/null | head -11 > "$LOG_DIR/top_processes_$$.tmp"
cat "$LOG_DIR/top_processes_$$.tmp" >> "$REPORT_FILE"
while IFS= read -r line; do
    report "  - $line"
done < "$LOG_DIR/top_processes_$$.tmp"
rm -f "$LOG_DIR/top_processes_$$.tmp"

# ============================
# 6. GOOGLE DRIVE OFFLOAD CHECK
# ============================
log ""
log "--- 6. GOOGLE DRIVE OFFLOAD CHECK ---"
report ""
report "## 6. Google Drive Offload Check"
report ""

if [ -d "$GDRIVE_BASE" ]; then
    GDRIVE_MOUNT=$(find "$GDRIVE_BASE" -maxdepth 1 -type d -name "GoogleDrive*" 2>/dev/null | head -1)
    if [ -n "$GDRIVE_MOUNT" ]; then
        log "Google Drive mounted: $GDRIVE_MOUNT"
        report "- Google Drive: mounted ✅"
        # Offload lane sizes
        for lane in 01_Downloads_Hourly 02_Large_Files 03_Installers_DMG 04_Images_Media 05_Archive_ZIP 06_Scripts_Terminal 07_VSCode_Workspaces 08_Misc; do
            lane_path="$GDRIVE_DIR/$lane"
            if [ -d "$lane_path" ]; then
                lane_size=$(du -sh "$lane_path" 2>/dev/null | awk '{print $1}')
                log "Offload lane $lane: $lane_size"
                report "- Offload lane $lane: $lane_size"
            fi
        done
    else
        log "Google Drive mount not found"
        report "- Google Drive: not mounted ⚠️"
        HEALTH_SCORE=$((HEALTH_SCORE - 5))
    fi
else
    log "Google Drive base directory not found"
    report "- Google Drive: not found ⚠️"
fi

# ============================
# 7. SECURITY & CONFIG AUDIT
# ============================
log ""
log "--- 7. SECURITY & CONFIG AUDIT ---"
report ""
report "## 7. Security & Config Audit"
report ""

# FileVault status
FV_STATUS=$(fdesetup status 2>/dev/null)
log "FileVault: $FV_STATUS"
report "- FileVault: $FV_STATUS"

# Firewall status
FW_STATUS=$(defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null)
if [ "$FW_STATUS" = "1" ]; then
    log "Firewall: ON"
    report "- Firewall: ON ✅"
elif [ "$FW_STATUS" = "0" ]; then
    log "Firewall: OFF"
    report "- Firewall: OFF ⚠️"
    HEALTH_SCORE=$((HEALTH_SCORE - 5))
else
    log "Firewall: status unknown ($FW_STATUS)"
    report "- Firewall: unknown ($FW_STATUS)"
fi

# SIP status
SIP_STATUS=$(csrutil status 2>/dev/null)
log "SIP: $SIP_STATUS"
report "- SIP: $SIP_STATUS"

# SSH status
SSH_STATUS=$(sudo systemsetup -getremotelogin 2>/dev/null || echo "unknown")
log "SSH: $SSH_STATUS"
report "- SSH: $SSH_STATUS"

# ============================
# 8. GITHUB & PROJECT STATUS
# ============================
log ""
log "--- 8. GITHUB & PROJECT STATUS ---"
report ""
report "## 8. GitHub & Project Status"
report ""

if [ -d "$USER_HOME/wsd-warp-control/.git" ]; then
    cd "$USER_HOME/wsd-warp-control" && git fetch --quiet 2>/dev/null
    AHEAD=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
    BEHIND=$(git rev-list origin/main..HEAD --count 2>/dev/null || echo "0")
    log "wsd-warp-control: ahead $AHEAD, behind $BEHIND"
    report "- wsd-warp-control: ahead $AHEAD, behind $BEHIND"
    if [ "$AHEAD" -gt 0 ]; then
        report "  - ⚠️ $AHEAD commits not pushed"
    fi
    if [ "$BEHIND" -gt 0 ]; then
        report "  - ⚠️ $BEHIND commits behind origin"
    fi
else
    log "wsd-warp-control: not a git repo"
    report "- wsd-warp-control: not a git repo"
fi

if [ -d "$USER_HOME/codex-wsd-control/.git" ]; then
    cd "$USER_HOME/codex-wsd-control" && git fetch --quiet 2>/dev/null
    AHEAD=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
    BEHIND=$(git rev-list origin/main..HEAD --count 2>/dev/null || echo "0")
    log "codex-wsd-control: ahead $AHEAD, behind $BEHIND"
    report "- codex-wsd-control: ahead $AHEAD, behind $BEHIND"
    if [ "$AHEAD" -gt 0 ]; then
        report "  - ⚠️ $AHEAD commits not pushed"
    fi
    if [ "$BEHIND" -gt 0 ]; then
        report "  - ⚠️ $BEHIND commits behind origin"
    fi
else
    log "codex-wsd-control: not a git repo"
    report "- codex-wsd-control: not a git repo"
fi

# ============================
# 9. HEALTH SCORE & SUMMARY
# ============================
log ""
log "--- 9. HEALTH SCORE & SUMMARY ---"
report ""
report "## 9. Health Score"
report ""

if [ "$HEALTH_SCORE" -lt 0 ]; then HEALTH_SCORE=0; fi
if [ "$HEALTH_SCORE" -gt 100 ]; then HEALTH_SCORE=100; fi

log "Health Score: $HEALTH_SCORE/100"
report "- **Health Score**: $HEALTH_SCORE/100"

if [ "$HEALTH_SCORE" -ge 90 ]; then
    report "- Status: 🟢 Excellent"
elif [ "$HEALTH_SCORE" -ge 70 ]; then
    report "- Status: 🟡 Good"
elif [ "$HEALTH_SCORE" -ge 50 ]; then
    report "- Status: 🟠 Fair — attention needed"
else
    report "- Status: 🔴 Poor — immediate action required"
fi

report ""
report "---"
report "Report generated: $(date)"
report "Log: $LOG_FILE"

log ""
log "======================================"
log "DAILY HEALTH CHECK COMPLETE"
log "Finished: $(date)"
log "Health Score: $HEALTH_SCORE/100"
log "Log: $LOG_FILE"
log "Report: $REPORT_FILE"
log "Space recovered: ${ACTUAL_FREED_MB}MB"
log "======================================"
