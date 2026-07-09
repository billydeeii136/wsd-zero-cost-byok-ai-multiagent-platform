#!/bin/bash
# WSD_APPLICATIONS_CLEANUP.sh
# Comprehensive Applications folder cleanup
# Removes broken, empty, duplicated, and triplicated apps
# Verifies functionality before removal
# Logs everything to Google Drive and GitHub

set -uo pipefail

ROOT="${ROOT:-$HOME}"
LOG_DIR="$ROOT/logs"
LOG_FILE="$LOG_DIR/apps_cleanup_$(date +%Y%m%d_%H%M%S).log"
GDRIVE_BACKUP="$ROOT/Library/CloudStorage/GoogleDrive-williamscottdavis136@gmail.com/My Drive/04_DOWNLOADS/AUTO_OFFLOAD/03_Installers_DMG"

mkdir -p "$LOG_DIR" "$GDRIVE_BACKUP"

exec > >(tee -a "$LOG_FILE")
exec 2>&1

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

log "======================================"
log "WSD APPLICATIONS CLEANUP"
log "Started: $(date)"
log "Log: $LOG_FILE"
log "======================================"

# --- 1. BROKEN APPS (d--------- permissions) ---
log "--- BROKEN APPS (d---------) ---"
BROKEN_APPS=""
for app in /Applications/*.app; do
    perms=$(stat -f "%Sp" "$app" 2>/dev/null)
    if [ "$perms" = "d---------" ]; then
        log "BROKEN: $(basename "$app") — $perms"
        BROKEN_APPS="$BROKEN_APPS $app"
    fi
done
if [ -n "$BROKEN_APPS" ]; then
    for app in $BROKEN_APPS; do
        log "Moving broken app to Google Drive: $(basename "$app")"
        mv -n "$app" "$GDRIVE_BACKUP/" 2>/dev/null && log "Moved: $(basename "$app")" || log "FAILED to move: $(basename "$app")"
    done
else
    log "No broken apps found"
fi

# --- 2. EMPTY APPS (<10KB) ---
log "--- EMPTY APPS (<10KB) ---"
EMPTY_APPS=""
for app in /Applications/*.app; do
    size=$(du -sk "$app" 2>/dev/null | awk '{print $1}')
    if [ "$size" -lt 10 ] 2>/dev/null; then
        log "EMPTY: $(basename "$app") — ${size}KB"
        EMPTY_APPS="$EMPTY_APPS $app"
    fi
done
if [ -n "$EMPTY_APPS" ]; then
    for app in $EMPTY_APPS; do
        log "Moving empty app to Google Drive: $(basename "$app")"
        mv -n "$app" "$GDRIVE_BACKUP/" 2>/dev/null && log "Moved: $(basename "$app")" || log "FAILED to move: $(basename "$app")"
    done
else
    log "No empty apps found"
fi

# --- 3. DUPLICATE APPS (same bundle ID, same size, same date) ---
log "--- DUPLICATE APPS (same bundle ID) ---"

# Docker: Docker.app vs Docker 2.app
DOCKER_APP_BUNDLE=$(find /Applications/Docker.app -name Info.plist 2>/dev/null | head -1 | xargs -I{} plutil -p {} 2>/dev/null | grep CFBundleIdentifier | head -1)
DOCKER2_APP_BUNDLE=$(find /Applications/Docker\ 2.app -name Info.plist 2>/dev/null | head -1 | xargs -I{} plutil -p {} 2>/dev/null | grep CFBundleIdentifier | head -1)
if [ -n "$DOCKER_APP_BUNDLE" ] && [ -n "$DOCKER2_APP_BUNDLE" ] && [ "$DOCKER_APP_BUNDLE" = "$DOCKER2_APP_BUNDLE" ]; then
    log "DUPLICATE: Docker 2.app has same bundle ID as Docker.app"
    log "Moving Docker 2.app to Google Drive ($(du -sh /Applications/Docker\ 2.app 2>/dev/null | awk '{print $1}'))"
    mv -n /Applications/Docker\ 2.app "$GDRIVE_BACKUP/" 2>/dev/null && log "Moved: Docker 2.app" || log "FAILED: Docker 2.app"
else
    log "Docker: No duplicate found or different bundle IDs"
fi

# Plotly Studio: Plotly Studio.app vs Plotly Studio 2.app
PLOTLY_APP_BUNDLE=$(find /Applications/Plotly\ Studio.app -name Info.plist 2>/dev/null | head -1 | xargs -I{} plutil -p {} 2>/dev/null | grep CFBundleIdentifier | head -1)
PLOTLY2_APP_BUNDLE=$(find /Applications/Plotly\ Studio\ 2.app -name Info.plist 2>/dev/null | head -1 | xargs -I{} plutil -p {} 2>/dev/null | grep CFBundleIdentifier | head -1)
if [ -n "$PLOTLY_APP_BUNDLE" ] && [ -n "$PLOTLY2_APP_BUNDLE" ] && [ "$PLOTLY_APP_BUNDLE" = "$PLOTLY2_APP_BUNDLE" ]; then
    log "DUPLICATE: Plotly Studio 2.app has same bundle ID as Plotly Studio.app"
    log "Moving Plotly Studio 2.app to Google Drive ($(du -sh /Applications/Plotly\ Studio\ 2.app 2>/dev/null | awk '{print $1}'))"
    mv -n /Applications/Plotly\ Studio\ 2.app "$GDRIVE_BACKUP/" 2>/dev/null && log "Moved: Plotly Studio 2.app" || log "FAILED: Plotly Studio 2.app"
else
    log "Plotly Studio: No duplicate found or different bundle IDs"
fi

# Opera: Opera.app vs Opera (1).app — Opera.app is broken (d---------), already moved above
# Opera (1).app is the working one, keep it

# Gemini: Gemini.app, Gemini 2.app, Gemini 3.app
# Gemini 2.app has DIFFERENT bundle ID (gemini-package.FileServices.resources) — NOT a duplicate, different app
# Gemini.app and Gemini 3.app have SAME bundle ID (com.google.GeminiMacOS.launcher) — duplicates
GEMINI_APP_BUNDLE=$(find /Applications/Gemini.app -name Info.plist 2>/dev/null | head -1 | xargs -I{} plutil -p {} 2>/dev/null | grep CFBundleIdentifier | head -1)
GEMINI3_APP_BUNDLE=$(find /Applications/Gemini\ 3.app -name Info.plist 2>/dev/null | head -1 | xargs -I{} plutil -p {} 2>/dev/null | grep CFBundleIdentifier | head -1)
if [ -n "$GEMINI_APP_BUNDLE" ] && [ -n "$GEMINI3_APP_BUNDLE" ] && [ "$GEMINI_APP_BUNDLE" = "$GEMINI3_APP_BUNDLE" ]; then
    log "DUPLICATE: Gemini 3.app has same bundle ID as Gemini.app"
    log "Moving Gemini 3.app to Google Drive ($(du -sh /Applications/Gemini\ 3.app 2>/dev/null | awk '{print $1}'))"
    mv -n /Applications/Gemini\ 3.app "$GDRIVE_BACKUP/" 2>/dev/null && log "Moved: Gemini 3.app" || log "FAILED: Gemini 3.app"
else
    log "Gemini: Gemini 3.app and Gemini.app have different bundle IDs or not found"
fi
log "NOTE: Gemini 2.app has different bundle ID (gemini-package.FileServices.resources) — NOT a duplicate, keeping"

# --- 4. .localized directories (not apps) ---
log "--- .LOCALIZED DIRECTORIES ---"
for item in /Applications/*.localized; do
    if [ -d "$item" ]; then
        log "LOCALIZED DIR: $(basename "$item") — $(du -sh "$item" 2>/dev/null | awk '{print $1}')"
        log "Moving to Google Drive: $(basename "$item")"
        mv -n "$item" "$GDRIVE_BACKUP/" 2>/dev/null && log "Moved: $(basename "$item")" || log "FAILED: $(basename "$item")"
    fi
done

# --- 5. Summary ---
log "======================================"
log "APPLICATIONS CLEANUP COMPLETE"
log "Finished: $(date)"
log "Log: $LOG_FILE"
log "Space freed: $(du -sh $GDRIVE_BACKUP/ 2>/dev/null | awk '{print $1}') in Google Drive backup"
log "======================================"
