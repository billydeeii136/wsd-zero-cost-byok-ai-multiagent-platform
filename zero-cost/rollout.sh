#!/bin/bash
set -u

ZERO_COST_DIR="${ZERO_COST_DIR:-$HOME/.config/zero-cost}"
HOSTS_FILE="$ZERO_COST_DIR/hosts.txt"
DRY_RUN=1
INCLUDE_SECRETS=0
TARGET_COUNT=0
FAILURE_COUNT=0

usage() {
    cat <<'EOF'
Usage: rollout.sh [--hosts-file <path>] [--apply|--dry-run] [--include-secrets]

Target file format (one per line):
  ssh <user@host> [port]
  adb <device_serial>

Notes:
  --dry-run          Print actions only (default)
  --apply            Execute actions
  --include-secrets  Also copy ~/.warp/byok-key-inventory.env to targets
EOF
}

trim_line() {
    local s="$1"
    s="${s%%#*}"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

run_or_print() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '[dry-run] %s\n' "$*"
        return 0
    fi
    "$@"
}

deploy_ssh() {
    local target="$1"
    local port="$2"
    TARGET_COUNT=$((TARGET_COUNT + 1))

    run_or_print ssh -p "$port" "$target" "mkdir -p ~/.config/zero-cost ~/.warp" || return 1
    run_or_print rsync -az -e "ssh -p $port" \
        "$ZERO_COST_DIR/profile.sh" \
        "$ZERO_COST_DIR/warp-guard.sh" \
        "$ZERO_COST_DIR/rollout.sh" \
        "$target:~/.config/zero-cost/" || return 1

    if [ "$INCLUDE_SECRETS" -eq 1 ] && [ -f "$HOME/.warp/byok-key-inventory.env" ]; then
        run_or_print rsync -az -e "ssh -p $port" \
            "$HOME/.warp/byok-key-inventory.env" \
            "$target:~/.warp/byok-key-inventory.env" || return 1
    fi

    local ensure_profile
    ensure_profile='grep -q "zero-cost/profile.sh" ~/.bash_profile 2>/dev/null || printf "\nif [ -f \"$HOME/.config/zero-cost/profile.sh\" ]; then\n    source \"$HOME/.config/zero-cost/profile.sh\"\nfi\n" >> ~/.bash_profile'
    run_or_print ssh -p "$port" "$target" "$ensure_profile" || return 1
    return 0
}

deploy_adb() {
    local serial="$1"
    TARGET_COUNT=$((TARGET_COUNT + 1))

    if [ "$DRY_RUN" -eq 0 ]; then
        adb -s "$serial" get-state >/dev/null 2>&1 || {
            printf '[error] %s: adb target not reachable.\n' "$serial" >&2
            return 1
        }
    fi

    run_or_print adb -s "$serial" shell "mkdir -p /sdcard/zero-cost" || return 1
    run_or_print adb -s "$serial" push "$ZERO_COST_DIR/profile.sh" "/sdcard/zero-cost/profile.sh" || return 1
    run_or_print adb -s "$serial" push "$ZERO_COST_DIR/warp-guard.sh" "/sdcard/zero-cost/warp-guard.sh" || return 1
    run_or_print adb -s "$serial" push "$ZERO_COST_DIR/rollout.sh" "/sdcard/zero-cost/rollout.sh" || return 1

    if [ "$INCLUDE_SECRETS" -eq 1 ] && [ -f "$HOME/.warp/byok-key-inventory.env" ]; then
        run_or_print adb -s "$serial" push "$HOME/.warp/byok-key-inventory.env" "/sdcard/zero-cost/byok-key-inventory.env" || return 1
    fi

    if [ "$DRY_RUN" -eq 0 ]; then
        adb -s "$serial" shell "test -d /data/data/com.termux/files/home" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            adb -s "$serial" shell "mkdir -p /data/data/com.termux/files/home/.config/zero-cost" >/dev/null 2>&1
            adb -s "$serial" shell "cp /sdcard/zero-cost/profile.sh /data/data/com.termux/files/home/.config/zero-cost/profile.sh" >/dev/null 2>&1
            adb -s "$serial" shell "cp /sdcard/zero-cost/warp-guard.sh /data/data/com.termux/files/home/.config/zero-cost/warp-guard.sh" >/dev/null 2>&1
            adb -s "$serial" shell 'grep -q "zero-cost/profile.sh" /data/data/com.termux/files/home/.bash_profile 2>/dev/null || printf "\nif [ -f \"$HOME/.config/zero-cost/profile.sh\" ]; then\n    source \"$HOME/.config/zero-cost/profile.sh\"\nfi\n" >> /data/data/com.termux/files/home/.bash_profile' >/dev/null 2>&1
        else
            printf '[info] %s: files pushed to /sdcard/zero-cost (Termux home not accessible via adb shell).\n' "$serial"
        fi
    fi
    return 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        --hosts-file)
            HOSTS_FILE="$2"
            shift 2
            ;;
        --apply)
            DRY_RUN=0
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --include-secrets)
            INCLUDE_SECRETS=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown argument: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ ! -f "$HOSTS_FILE" ]; then
    printf 'Hosts file not found: %s\n' "$HOSTS_FILE" >&2
    exit 1
fi


if ! command -v rsync >/dev/null 2>&1; then
    printf 'rsync is required for SSH rollout.\n' >&2
    exit 1
fi

while IFS= read -r raw || [ -n "$raw" ]; do
    line="$(trim_line "$raw")"
    [ -z "$line" ] && continue

    set -- $line
    transport="${1:-}"

    case "$transport" in
        ssh)
            target="${2:-}"
            port="${3:-22}"
            if [ -z "$target" ]; then
                printf 'Skipping malformed SSH entry: %s\n' "$raw" >&2
                continue
            fi
            if ! deploy_ssh "$target" "$port"; then
                FAILURE_COUNT=$((FAILURE_COUNT + 1))
                printf '[error] SSH rollout failed for %s:%s\n' "$target" "$port" >&2
            fi
            ;;
        adb)
            serial="${2:-}"
            if [ -z "$serial" ]; then
                printf 'Skipping malformed ADB entry: %s\n' "$raw" >&2
                continue
            fi
            if ! command -v adb >/dev/null 2>&1; then
                printf 'adb not found; skipping %s\n' "$serial" >&2
                continue
            fi
            if ! deploy_adb "$serial"; then
                FAILURE_COUNT=$((FAILURE_COUNT + 1))
                printf '[error] ADB rollout failed for %s\n' "$serial" >&2
            fi
            ;;
        *)
            printf 'Skipping unknown transport entry: %s\n' "$raw" >&2
            ;;
    esac
done < "$HOSTS_FILE"

if [ "$TARGET_COUNT" -eq 0 ]; then
    printf 'No valid targets in %s\n' "$HOSTS_FILE"
    exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Dry run complete. Targets parsed: %s, failures: %s\n' "$TARGET_COUNT" "$FAILURE_COUNT"
else
    printf 'Rollout complete. Targets parsed: %s, failures: %s\n' "$TARGET_COUNT" "$FAILURE_COUNT"
fi

if [ "$FAILURE_COUNT" -gt 0 ]; then
    exit 1
fi
