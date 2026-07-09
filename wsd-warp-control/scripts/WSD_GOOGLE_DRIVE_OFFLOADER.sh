#!/bin/bash
# WSD_GOOGLE_DRIVE_OFFLOADER.sh
# Cross-lane automated offload system for Google Drive
# Integrates with Codex lanes, WARP, Terminal, VS Code, and all WSD systems
# Naming convention: 01_LEGAL, 02_PROJECTS, 03_PERSONAL, 04_DOWNLOADS, 05_BACKUPS, 06_TOOLS_REFERENCE, 07_ENTERPRISE, 08_ARCHIVE
# Jailed layer: cumseeme.live separate
# Run: bash ~/WSD_GOOGLE_DRIVE_OFFLOADER.sh

set -uo pipefail

ROOT="${ROOT:-$HOME}"
LOG_DIR="$ROOT/logs"
LOG_FILE="$LOG_DIR/gdrive_offloader_$(date +%Y%m%d_%H%M%S).log"
GDRIVE_BASE="$ROOT/Library/CloudStorage/GoogleDrive-williamscottdavis136@gmail.com/My Drive"
GDRIVE_OFFLOAD="$GDRIVE_BASE/04_DOWNLOADS/AUTO_OFFLOAD"
MARKER_DIR="$ROOT/.wsd_offload_markers"

mkdir -p "$LOG_DIR" "$MARKER_DIR"

exec > >(tee -a "$LOG_FILE")
exec 2>&1

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

log "======================================"
log "WSD GOOGLE DRIVE OFFLOADER"
log "Started: $(date)"
log "Log: $LOG_FILE"
log "======================================"

# --- 1. Verify Google Drive mount ---
if [ ! -d "$GDRIVE_BASE" ]; then
    log "ERROR: Google Drive not mounted at $GDRIVE_BASE"
    log "Ensure Google Drive is running and syncing."
    exit 1
fi

# Create offload subdirectories matching Codex convention
mkdir -p "$GDRIVE_OFFLOAD"/{"01_Downloads_Hourly","02_Large_Files","03_Installers_DMG","04_Images_Media","05_Archive_ZIP","06_Scripts_Terminal","07_VSCode_Workspaces","08_Misc"}

log "Google Drive offload lanes ready."

# --- 2. Hourly Downloads Cleanup ---
log "--- DOWNLOADS HOURLY CLEANUP ---"
DOWNLOADS="$ROOT/Downloads"
if [ -d "$DOWNLOADS" ]; then
    # Files older than 1 hour (or > 50MB immediate)
    find "$DOWNLOADS" -maxdepth 1 -type f -mmin +60 -print0 2>/dev/null | while IFS= read -r -d '' file; do
        dest="$GDRIVE_OFFLOAD/01_Downloads_Hourly"
        if [ -f "$file" ] && [ ! -f "$MARKER_DIR/$(basename "$file").done" ]; then
            mv -n "$file" "$dest/" 2>/dev/null && touch "$MARKER_DIR/$(basename "$file").done" && log "Moved (age>1h): $(basename "$file")"
        fi
    done
    # Large files (>50MB) move immediately regardless of age
    find "$DOWNLOADS" -maxdepth 1 -type f -size +50M -print0 2>/dev/null | while IFS= read -r -d '' file; do
        dest="$GDRIVE_OFFLOAD/02_Large_Files"
        if [ -f "$file" ] && [ ! -f "$MARKER_DIR/$(basename "$file").done" ]; then
            mv -n "$file" "$dest/" 2>/dev/null && touch "$MARKER_DIR/$(basename "$file").done" && log "Moved (large): $(basename "$file")"
        fi
    done
fi

# --- 3. Installer/DMG offloads from Desktop, Documents, Home ---
log "--- INSTALLER/DMG OFFLOAD ---"
for scan_dir in "$ROOT/Desktop" "$ROOT/Documents" "$ROOT"; do
    [ -d "$scan_dir" ] || continue
    find "$scan_dir" -maxdepth 1 -type f \( -iname "*.dmg" -o -iname "*.pkg" -o -iname "*.exe" -o -iname "*.msi" -o -iname "*.zip" -o -iname "*.tar.gz" \) -size +10M -print0 2>/dev/null | while IFS= read -r -d '' file; do
        dest="$GDRIVE_OFFLOAD/03_Installers_DMG"
        if [ -f "$file" ] && [ ! -f "$MARKER_DIR/$(basename "$file").done" ]; then
            mv -n "$file" "$dest/" 2>/dev/null && touch "$MARKER_DIR/$(basename "$file").done" && log "Moved (installer): $(basename "$file")"
        fi
    done
done

# --- 4. Image/Media offload from Desktop ---
log "--- IMAGE/MEDIA OFFLOAD ---"
for scan_dir in "$ROOT/Desktop" "$ROOT/Documents" "$ROOT/Pictures"; do
    [ -d "$scan_dir" ] || continue
    find "$scan_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" \) -size +20M -print0 2>/dev/null | while IFS= read -r -d '' file; do
        dest="$GDRIVE_OFFLOAD/04_Images_Media"
        if [ -f "$file" ] && [ ! -f "$MARKER_DIR/$(basename "$file").done" ]; then
            mv -n "$file" "$dest/" 2>/dev/null && touch "$MARKER_DIR/$(basename "$file").done" && log "Moved (media): $(basename "$file")"
        fi
    done
done

# --- 5. Archive old ZIPs/tarballs from home ---
log "--- ARCHIVE OFFLOAD ---"
for scan_dir in "$ROOT" "$ROOT/Documents"; do
    [ -d "$scan_dir" ] || continue
    find "$scan_dir" -maxdepth 1 -type f \( -iname "*.zip" -o -iname "*.tar.gz" -o -iname "*.tar.bz2" -o -iname "*.7z" \) -mtime +7 -print0 2>/dev/null | while IFS= read -r -d '' file; do
        dest="$GDRIVE_OFFLOAD/05_Archive_ZIP"
        if [ -f "$file" ] && [ ! -f "$MARKER_DIR/$(basename "$file").done" ]; then
            mv -n "$file" "$dest/" 2>/dev/null && touch "$MARKER_DIR/$(basename "$file").done" && log "Moved (archive): $(basename "$file")"
        fi
    done
done

# --- 6. Terminal scripts (.sh) offload from home (non-active) ---
log "--- SCRIPT OFFLOAD ---"
# Move ALL non-active .sh from home (no size limit)
find "$ROOT" -maxdepth 1 -type f -name "*.sh" -print0 2>/dev/null | while IFS= read -r -d '' file; do
    base=$(basename "$file")
    # Keep all active WSD system scripts
    case "$base" in
        wsd_mac_ultimate_optimizer.sh|WSD_GOOGLE_DRIVE_OFFLOADER.sh|WSD_CROSS_SYSTEM_COORDINATOR.sh|\
        WSD_CCOS_EMERGENCY_RECOVERY.sh|WSD_CLOUD_AUTH_ACCESS.sh|WSD_COMPLETE_MAC_CLOUD_INVENTORY.sh|\
        WSD_COMPREHENSIVE_SPACE_RECOVERY.sh|WSD_DUPLICATE_AND_SPACE_AUDIT.sh|WSD_ENHANCED_SPACE_AUDIT.sh|\
        WSD_FAST_MAC_CLOUD_INVENTORY.sh|WSD_FINAL_HARVEST.sh|WSD_MAC_CLOUD_AUDIT.sh|WSD_WRANGLER_AUTH_AND_VERIFY.sh) continue ;;
    esac
    dest="$GDRIVE_OFFLOAD/06_Scripts_Terminal"
    if [ -f "$file" ] && [ ! -f "$MARKER_DIR/$base.done" ]; then
        mv -n "$file" "$dest/" 2>/dev/null && touch "$MARKER_DIR/$base.done" && log "Moved (script): $base"
    fi
done

# --- 7. VS Code workspace/workspaceStorage cleanup ---
log "--- VS CODE OPTIMIZATION ---"
VSCODE_SUPPORT="$ROOT/Library/Application Support/Code"
VSCODE_WORKSPACE_STORAGE="$VSCODE_SUPPORT/User/workspaceStorage"
VSCODE_GLOBAL_STORAGE="$VSCODE_SUPPORT/User/globalStorage"
VSCODE_BACKUP="$VSCODE_SUPPORT/Backups"
VSCODE_CACHE="$VSCODE_SUPPORT/Cache"

if [ -d "$VSCODE_WORKSPACE_STORAGE" ]; then
    OLD_WS=$(find "$VSCODE_WORKSPACE_STORAGE" -maxdepth 1 -type d -mtime +30 2>/dev/null | wc -l | tr -d ' ')
    find "$VSCODE_WORKSPACE_STORAGE" -maxdepth 1 -type d -mtime +30 -exec rm -rf {} + 2>/dev/null
    log "VS Code: Cleaned $OLD_WS old workspace storage folders (>30 days)"
fi

if [ -d "$VSCODE_BACKUP" ]; then
    find "$VSCODE_BACKUP" -type f -mtime +7 -delete 2>/dev/null
    log "VS Code: Cleaned old backups (>7 days)"
fi

if [ -d "$VSCODE_CACHE" ]; then
    find "$VSCODE_CACHE" -type f -mtime +7 -delete 2>/dev/null
    log "VS Code: Cleaned old cache (>7 days)"
fi

# VS Code offloads: large extension caches, extension backups
VSCODE_EXTENSIONS="$VSCODE_SUPPORT/extensions"
if [ -d "$VSCODE_EXTENSIONS" ]; then
    EXT_DUPE=$(find "$VSCODE_EXTENSIONS" -maxdepth 1 -type d -name "*-[0-9]*.[0-9]*.[0-9]*" 2>/dev/null | sort -t- -k2 -rn | awk -F- '{base=$1; for(i=2;i<NF;i++)base=base"-"$i; if(base==last) print; last=base}' | wc -l | tr -d ' ')
    log "VS Code: $EXT_DUPE duplicate extension versions detected (manual review recommended)"
fi

# VS Code workspace files in home -> move to Projects lane
for vsc_file in "$ROOT"/*.code-workspace; do
    [ -f "$vsc_file" ] || continue
    dest="$GDRIVE_OFFLOAD/07_VSCode_Workspaces"
    if [ ! -f "$MARKER_DIR/$(basename "$vsc_file").done" ]; then
        cp -n "$vsc_file" "$dest/" 2>/dev/null && touch "$MARKER_DIR/$(basename "$vsc_file").done" && log "Copied workspace: $(basename "$vsc_file")"
    fi
done

# --- 8. Disk status report ---
log "--- DISK STATUS ---"
DF_PCT=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
DF_AVAIL=$(df -h / | awk 'NR==2{print $4}')
log "Disk usage: ${DF_PCT}% (available: $DF_AVAIL)"

# --- 9. Summary ---
log "======================================"
log "OFFLOADER COMPLETE"
log "Finished: $(date)"
log "Log: $LOG_FILE"
log "======================================"

# --- 10. GitHub sync ---
log "--- GITHUB SYNC ---"
for repo in "$ROOT/wsd-warp-control" "$ROOT/codex-wsd-control"; do
    if [ -d "$repo/.git" ]; then
        cd "$repo"
        git add -A 2>/dev/null
        git commit -m "auto-offload: $(date +%Y%m%d_%H%M%S) disk=$DF_PCT% avail=$DF_AVAIL

Co-Authored-By: Oz <oz-agent@warp.dev>" 2>/dev/null
        git push origin main 2>/dev/null && log "Pushed: $(basename "$repo")" || log "Push failed or no changes: $(basename "$repo")"
    fi
done

log "All systems coordinated."
