#!/bin/bash
# Lists all available WARP_ZERO_COST modes defined under ~/.config/zero-cost/modes/.
# Usage: list-modes.sh [--json]

MODES_DIR="${ZERO_COST_MODES_DIR:-$HOME/.config/zero-cost/modes}"
ACTIVE_POINTER="$HOME/.config/zero-cost/active-mode-name.txt"
JSON_OUT=0

if [ "${1:-}" = "--json" ]; then
    JSON_OUT=1
fi

if [ ! -d "$MODES_DIR" ]; then
    printf 'No modes directory found at %s\n' "$MODES_DIR" >&2
    exit 1
fi

ACTIVE_FILE=""
if [ -f "$ACTIVE_POINTER" ]; then
    ACTIVE_FILE="$(cat "$ACTIVE_POINTER" 2>/dev/null)"
fi

if command -v python3 >/dev/null 2>&1; then
    python3 - "$MODES_DIR" "$ACTIVE_FILE" "$JSON_OUT" <<'PY'
import glob
import json
import os
import sys

modes_dir, active_file, json_out = sys.argv[1], sys.argv[2], sys.argv[3] == "1"

entries = []
for path in sorted(glob.glob(os.path.join(modes_dir, "mode-*.sh"))):
    with open(path) as f:
        for line in f:
            if line.startswith("# META:"):
                meta = json.loads(line[len("# META:"):].strip())
                meta["file"] = os.path.basename(path)
                meta["active"] = meta["file"] == active_file
                entries.append(meta)
                break

if json_out:
    print(json.dumps(entries, indent=2))
else:
    header = ("ID", "SLUG", "TIER", "SCOPE", "MODEL", "DESCRIPTION")
    widths = (4, 24, 12, 20, 32, 60)
    fmt = "".join("{:%d}" % w for w in widths)
    print(fmt.format(*header))
    print(fmt.format(*("-" * (w - 1) for w in widths)))
    for e in entries:
        mark = "*" if e["active"] else " "
        model = e["model"] if len(e["model"]) <= 30 else e["model"][:29] + "\u2026"
        desc = e["desc"] if len(e["desc"]) <= 58 else e["desc"][:57] + "\u2026"
        print(fmt.format(mark + e["id"], e["slug"], e["tier"], e["scope"], model, desc))
    print("")
    print("* = currently active mode (via select-mode.sh)")
    print("Activate a mode:   source ~/.config/zero-cost/select-mode.sh <id-or-slug>")
    print("Cost tiers:  local-free = $0 always  |  byok-remote = your own provider key, $0 Warp credits  |  hybrid = local-first with BYOK fallback")
PY
else
    printf '%-4s %-24s %-12s %s\n' "ID" "SLUG" "TIER" "DESCRIPTION"
    for f in "$MODES_DIR"/mode-*.sh; do
        grep -h '^# META:' "$f"
    done
fi
