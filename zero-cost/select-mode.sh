#!/bin/bash
# Selects one of the 30 WARP_ZERO_COST modes under ~/.config/zero-cost/modes/.
#
# Usage:
#   source ~/.config/zero-cost/select-mode.sh <id|slug>
#   source ~/.config/zero-cost/select-mode.sh 07
#   source ~/.config/zero-cost/select-mode.sh ollama-command-r
#
# Must be *sourced* (not executed) to take effect in your current shell.
# Either way, the choice is persisted so new shells pick it up automatically
# via profile.sh.

ZERO_COST_MODES_DIR="${ZERO_COST_MODES_DIR:-$HOME/.config/zero-cost/modes}"
ZERO_COST_ACTIVE_POINTER="$HOME/.config/zero-cost/active-mode-name.txt"

_zc_is_sourced() {
    ( return 0 2>/dev/null )
}

_zc_arg="${1:-}"

if [ -z "$_zc_arg" ]; then
    printf 'Usage: source select-mode.sh <id|slug>\n' >&2
    printf 'Run list-modes.sh to see all 30 available modes.\n' >&2
    if _zc_is_sourced; then return 1; else exit 1; fi
fi

_zc_norm_id=""
case "$_zc_arg" in
    ''|*[!0-9]*) _zc_norm_id="" ;;
    *) _zc_norm_id="$(printf '%02d' "$_zc_arg" 2>/dev/null)" ;;
esac

_zc_match=""
for _zc_f in "$ZERO_COST_MODES_DIR"/mode-*.sh; do
    [ -f "$_zc_f" ] || continue
    _zc_base="$(basename "$_zc_f")"
    _zc_id_part="$(printf '%s' "$_zc_base" | sed -E 's/^mode-([0-9]+)-.*/\1/')"
    _zc_slug_part="$(printf '%s' "$_zc_base" | sed -E 's/^mode-[0-9]+-(.*)\.sh$/\1/')"

    if [ "$_zc_arg" = "$_zc_id_part" ] || { [ -n "$_zc_norm_id" ] && [ "$_zc_norm_id" = "$_zc_id_part" ]; } || [ "$_zc_arg" = "$_zc_slug_part" ]; then
        _zc_match="$_zc_f"
        break
    fi
done

if [ -z "$_zc_match" ]; then
    printf 'No mode matches "%s". Run list-modes.sh to see all 30 available modes.\n' "$_zc_arg" >&2
    unset _zc_arg _zc_norm_id _zc_match _zc_f _zc_base _zc_id_part _zc_slug_part
    if _zc_is_sourced; then return 1; else exit 1; fi
fi

mkdir -p "$(dirname "$ZERO_COST_ACTIVE_POINTER")"
basename "$_zc_match" > "$ZERO_COST_ACTIVE_POINTER"
printf '[zero-cost] Active mode set to: %s\n' "$(basename "$_zc_match")"

if _zc_is_sourced; then
    # shellcheck disable=SC1090
    source "$_zc_match"
    printf '[zero-cost] Applied to this shell session.\n'
else
    printf '[zero-cost] Saved. Run: source "%s/profile.sh"  (or open a new terminal) to activate.\n' "$(dirname "$ZERO_COST_ACTIVE_POINTER")"
fi

unset _zc_arg _zc_norm_id _zc_match _zc_f _zc_base _zc_id_part _zc_slug_part
