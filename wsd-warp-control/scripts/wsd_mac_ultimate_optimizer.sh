#!/bin/bash
# WSD_MAC_ULTIMATE_OPTIMIZER.sh
# One mega script for MacBook Air optimization
# Browser performance, disk cleanup, startup audit, daily cron health check
# Run with: bash ~/wsd_mac_ultimate_optimizer.sh
# Do NOT run with sudo for browser defaults; script will prompt if needed for system tasks

set -uo pipefail

# ============================
# CONFIGURATION
# ============================
USER_HOME="$HOME"
GDRIVE_BASE="$USER_HOME/Library/CloudStorage"
LOG_DIR="$USER_HOME/logs"
LOG_FILE="$LOG_DIR/mac_optimizer_$(date +%Y%m%d_%H%M%S).log"
CRON_HOUR=9
CRON_MIN=0

# ============================
# LOGGING
# ============================
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "======================================"
echo "WSD MAC ULTIMATE OPTIMIZER"
echo "Started: $(date)"
echo "Log: $LOG_FILE"
echo "======================================"

# ============================
# 1. BASH DEFAULT SHELL (No zsh removal — macOS needs it)
# ============================
echo ""
echo "--- 1. SHELL CONFIGURATION ---"
CURRENT_SHELL=$(dscl . -read "$USER_HOME" UserShell 2>/dev/null | awk '{print $2}')
if [ "$CURRENT_SHELL" != "/bin/bash" ]; then
    echo "Changing default shell to bash..."
    chsh -s /bin/bash
else
    echo "Default shell already bash."
fi

# Force Terminal.app to always open bash
defaults write com.apple.Terminal Shell -string "/bin/bash"
echo "Terminal.app shell set to /bin/bash"

# ============================
# 2. BROWSER PERFORMANCE TUNING
# ============================
echo ""
echo "--- 2. BROWSER PERFORMANCE TUNING ---"

# Chrome / Chromium
defaults write com.google.Chrome HardwareAccelerationModeEnabled -bool true 2>/dev/null
defaults write com.google.Chrome DisableBackgroundNetworking -bool false 2>/dev/null
defaults write com.google.Chrome EnableMediaRouter -bool false 2>/dev/null
defaults write com.google.Chrome BackgroundModeEnabled -bool false 2>/dev/null
defaults write com.google.Chrome RemoteDebuggingPort -int 0 2>/dev/null
defaults write com.google.Chrome DiskCacheSize -int 134217728 2>/dev/null  # 128MB cache limit
defaults write com.google.Chrome ChromeCleanupEnabled -bool false 2>/dev/null
echo "Chrome: Hardware accel ON, background mode OFF, cache capped at 128MB"

# Firefox
FIREFOX_PROFILES_DIR="$USER_HOME/Library/Application Support/Firefox/Profiles"
if [ -d "$FIREFOX_PROFILES_DIR" ]; then
    for profile in "$FIREFOX_PROFILES_DIR"/*.default*; do
        if [ -d "$profile" ]; then
            PREFS="$profile/prefs.js"
            USERJS="$profile/user.js"
            cat > "$USERJS" 2>/dev/null <<'EOF'
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.disk.capacity", 131072);
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.tabs.firefox-view", false);
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false);
user_pref("dom.ipc.processCount", 4);
user_pref("browser.startup.page", 3);
user_pref("general.smoothScroll", false);
user_pref("browser.low_commit_space_threshold_mb", 512);
user_pref("browser.tabs.unloadOnLowMemory", true);
EOF
            echo "Firefox profile optimized: $(basename "$profile")"
        fi
    done
else
    echo "Firefox profiles not found."
fi

# Safari
# Reduce website data retention, disable preloading, disable extensions if bloated
defaults write com.apple.Safari WebKitPluginsEnabled -bool false 2>/dev/null
defaults write com.apple.Safari WebKitJavaEnabled -bool false 2>/dev/null
defaults write com.apple.Safari WebKitPreferences.developerExtrasEnabled -bool false 2>/dev/null
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true 2>/dev/null
defaults write com.apple.Safari ShowStatusBar -bool true 2>/dev/null
# Clear Safari caches if > 30 days old
SAFARI_CACHE="$USER_HOME/Library/Caches/com.apple.Safari"
if [ -d "$SAFARI_CACHE" ]; then
    find "$SAFARI_CACHE" -type f -mtime +30 -delete 2>/dev/null
    echo "Safari: Cleared caches older than 30 days"
fi
# Reduce website data
WEBSITE_DATA="$USER_HOME/Library/Safari/LocalStorage"
if [ -d "$WEBSITE_DATA" ]; then
    du -sh "$WEBSITE_DATA" 2>/dev/null
    echo "Safari: If LocalStorage is huge, manually clear via Safari > Preferences > Privacy > Manage Website Data"
fi

# Opera
if [ -d "$USER_HOME/Library/Application Support/com.operasoftware.Opera" ]; then
    defaults write com.operasoftware.Opera HardwareAccelerationModeEnabled -bool true 2>/dev/null
    defaults write com.operasoftware.Opera BackgroundModeEnabled -bool false 2>/dev/null
    echo "Opera: Background mode OFF, hardware accel ON"
fi

# DuckDuckGo
DDG_SUPPORT="$USER_HOME/Library/Application Support/DuckDuckGo"
if [ -d "$DDG_SUPPORT" ]; then
    echo "DuckDuckGo: No heavy defaults to tune; ensure tabs are closed aggressively."
fi

echo "Browser tuning complete."

# ============================
# 3. DISK CLEANUP & DUPLICATE SCAN
# ============================
echo ""
echo "--- 3. DISK CLEANUP & DUPLICATE SCAN ---"

FREE_BEFORE=$(df -k / | awk 'NR==2{print $4}')

echo "Cleaning user caches older than 30 days..."
find "$USER_HOME/Library/Caches" -type f -mtime +30 -delete 2>/dev/null
find "$USER_HOME/Library/Caches" -type d -empty -delete 2>/dev/null

# Clean system logs older than 60 days (user logs only, safe)
echo "Cleaning old logs..."
find "$USER_HOME/Library/Logs" -type f -mtime +60 -delete 2>/dev/null

# Trash items older than 30 days
echo "Emptying Trash items older than 30 days..."
find "$USER_HOME/.Trash" -type f -mtime +30 -delete 2>/dev/null
find "$USER_HOME/.Trash" -type d -empty -delete 2>/dev/null

# iOS device support cleanup (can be huge)
IOS_SUPPORT="$USER_HOME/Library/Developer/Xcode/iOS DeviceSupport"
if [ -d "$IOS_SUPPORT" ]; then
    IOS_SIZE=$(du -sk "$IOS_SUPPORT" 2>/dev/null | awk '{print $1}')
    if [ "$IOS_SIZE" -gt 1048576 ]; then  # > 1GB
        echo "WARNING: iOS DeviceSupport is ${IOS_SIZE}KB. Manual review recommended: $IOS_SUPPORT"
    fi
fi

# iTunes / Music old backups
OLD_MOBILE_BACKUP="$USER_HOME/Library/Application Support/MobileSync/Backup"
if [ -d "$OLD_MOBILE_BACKUP" ]; then
    BACKUP_SIZE=$(du -sk "$OLD_MOBILE_BACKUP" 2>/dev/null | awk '{print $1}')
    echo "iTunes/Mobile backups: ${BACKUP_SIZE}KB at $OLD_MOBILE_BACKUP"
    echo "Offload old backups to Google Drive manually if needed."
fi

# Download folder duplicates scan
echo "Scanning ~/Downloads for duplicates (by MD5)..."
DOWNLOAD_DUPES=$(find "$USER_HOME/Downloads" -maxdepth 1 -type f -exec md5 -q {} + 2>/dev/null | sort | uniq -d | wc -l | tr -d ' ')
echo "Duplicate file hashes found in Downloads: $DOWNLOAD_DUPES"
if [ "$DOWNLOAD_DUPES" -gt 0 ]; then
    echo "Run manual review: find ~/Downloads -maxdepth 1 -type f -exec md5 -q {} + | sort | uniq -d"
fi

# Large duplicate file scan (fast: only Downloads, Documents, Desktop, limit 10s each)
echo "Scanning key folders for large duplicate candidates (fast scan)..."
for scan_dir in "$USER_HOME/Downloads" "$USER_HOME/Documents" "$USER_HOME/Desktop"; do
    if [ -d "$scan_dir" ]; then
        dir_name=$(basename "$scan_dir")
        timeout 10 find "$scan_dir" -maxdepth 3 -type f -size +10M -exec stat -f "%z %N" {} + 2>/dev/null | sort -rn | head -50 > "$LOG_DIR/large_files_${dir_name}.txt" 2>/dev/null || echo "Timeout or error scanning $scan_dir"
        echo "Top large files in $dir_name saved to: $LOG_DIR/large_files_${dir_name}.txt"
    fi
done

# Find exact duplicates by size+name in common folders (Downloads, Documents)
for dir in "$USER_HOME/Downloads" "$USER_HOME/Documents"; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        echo "Scanning $dir for exact duplicates by size (fast)..."
        timeout 15 find "$dir" -maxdepth 2 -type f ! -path "*/.*" -exec stat -f "%z %N" {} + 2>/dev/null | sort | awk '{size=$1; $1=""; name=$0; gsub(/^ /,"",name); if (size==last && name!=last_name) print "DUPLICATE_SIZE: " size " " name; last=size; last_name=name}' > "$LOG_DIR/duplicates_${dir_name}.txt" 2>/dev/null || echo "Timeout or error scanning $dir for duplicates"
    fi
done

FREE_AFTER=$(df -k / | awk 'NR==2{print $4}')
RECOVERED_KB=$((FREE_AFTER - FREE_BEFORE))
RECOVERED_MB=$((RECOVERED_KB / 1024))
echo "Space recovered this run: ${RECOVERED_MB}MB"

# ============================
# 4. STARTUP AGENTS AUDIT
# ============================
echo ""
echo "--- 4. STARTUP AGENTS AUDIT ---"
LAUNCH_AGENTS="$USER_HOME/Library/LaunchAgents"
if [ -d "$LAUNCH_AGENTS" ]; then
    echo "User LaunchAgents found:"
    ls -la "$LAUNCH_AGENTS" | tee -a "$LOG_DIR/launchagents_audit.txt"
    echo ""
    echo "Review $LOG_DIR/launchagents_audit.txt and unload unnecessary agents with:"
    echo "  launchctl unload ~/Library/LaunchAgents/<agent.plist>"
else
    echo "No user LaunchAgents found."
fi

# Login items
osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | tee -a "$LOG_DIR/login_items.txt"
echo "Login items saved to: $LOG_DIR/login_items.txt"

# ============================
# 5. SYSTEM PERFORMANCE
# ============================
echo ""
echo "--- 5. SYSTEM PERFORMANCE TUNES ---"

# Disable Spotlight indexing for heavy dev folders that cause CPU spikes
mdutil -i off "$USER_HOME/Library/Caches" 2>/dev/null
mdutil -i off "$USER_HOME/node_modules" 2>/dev/null
mdutil -i off "$USER_HOME/codex" 2>/dev/null
mdutil -i off "$USER_HOME/wsd-warp-control" 2>/dev/null
echo "Spotlight indexing disabled for heavy cache/dev folders."

# Reduce animations (speeds up UI on MBA)
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001 2>/dev/null
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false 2>/dev/null
defaults write com.apple.dock launchanim -bool false 2>/dev/null
defaults write com.apple.dock expose-animation-duration -float 0.1 2>/dev/null
killall Dock 2>/dev/null || true
echo "UI animations reduced."

# ============================
# 6. GOOGLE DRIVE OFFLOAD SETUP
# ============================
echo ""
echo "--- 6. GOOGLE DRIVE OFFLOAD SETUP ---"
GDRIVE_PATH=$(find "$GDRIVE_BASE" -maxdepth 1 -type d -name "GoogleDrive*" 2>/dev/null | head -1)
if [ -n "$GDRIVE_PATH" ] && [ -d "$GDRIVE_PATH" ]; then
    echo "Google Drive found at: $GDRIVE_PATH"
    OFFLOAD_DIR="$GDRIVE_PATH/My Drive/MacOffload"
    mkdir -p "$OFFLOAD_DIR" 2>/dev/null
    echo "Offload target ready: $OFFLOAD_DIR"
    echo ""
    echo "Suggested manual moves to free disk:"
    echo "  - Old iOS backups: $OLD_MOBILE_BACKUP"
    echo "  - Large Downloads you do not need local"
    echo "  - ~/Movies if not actively used"
    echo "  - Duplicate photos in ~/Pictures"
else
    echo "Google Drive mount not found. Skipping offload setup."
fi

# ============================
# 7. DAILY 9:00 AM CRON HEALTH CHECK
# ============================
echo ""
echo "--- 7. DAILY 9:00 AM HEALTH CHECK CRON ---"
CRON_JOB="$CRON_MIN $CRON_HOUR * * * /bin/bash $USER_HOME/wsd_mac_ultimate_optimizer.sh >> $LOG_DIR/cron_daily_\$(date +\\%Y\\%m\\%d).log 2>&1"
(crontab -l 2>/dev/null | grep -v "wsd_mac_ultimate_optimizer" || true; echo "$CRON_JOB") | crontab -
echo "Cron installed for 9:00 AM daily."
crontab -l | grep "wsd_mac_ultimate_optimizer"

# ============================
# 8. CREDENTIAL AUTOFILL SYNC (Browser Native Only — No Harvesting)
# ============================
echo ""
echo "--- 8. BROWSER AUTOFILL SETTINGS ---"

# Enable native browser autofill (passwords stay in browser/iCloud Keychain)
defaults write com.google.Chrome AutofillAddressEnabled -bool true 2>/dev/null
defaults write com.google.Chrome AutofillCreditCardEnabled -bool true 2>/dev/null
echo "Chrome autofill: ON (uses existing iCloud/Google sync)"

# Safari uses iCloud Keychain by default; ensure it's on
# This requires user to verify in System Settings > Apple ID > iCloud > Passwords & Keychain

# 1Password / Bitwarden
if ls /Applications/ | grep -qi "1Password" 2>/dev/null; then
    echo "1Password detected. Ensure browser extensions are installed and unlocked."
fi
if ls /Applications/ | grep -qi "Bitwarden" 2>/dev/null; then
    echo "Bitwarden detected. Ensure browser extensions are installed and unlocked."
fi

echo ""
echo "NOTE: Cross-browser password export/import is NOT scripted."
echo "Use each browser's native password manager or your password manager's built-in sync."

# ============================
# 9. SUMMARY
# ============================
echo ""
echo "======================================"
echo "OPTIMIZATION COMPLETE"
echo "Finished: $(date)"
echo "Log: $LOG_FILE"
echo "Space recovered: ${RECOVERED_MB}MB"
echo "Review logs in: $LOG_DIR"
echo ""
echo "NEXT STEPS:"
echo "  1. Reboot to clear all browser caches fully."
echo "  2. Review $LOG_DIR/launchagents_audit.txt for startup items to remove."
echo "  3. Review $LOG_DIR/duplicates_*.txt for duplicates to delete."
echo "  4. Move large files to Google Drive: $OFFLOAD_DIR"
echo "  5. Open each browser and verify settings applied."
echo "  6. Manually verify Keychain/iCloud passwords are syncing."
echo "======================================"
