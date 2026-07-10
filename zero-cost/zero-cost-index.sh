#!/bin/bash
# Master index for all zero-cost AI resources: the 30 WARP_ZERO_COST modes
# plus independently-maintained zero-cost projects elsewhere on this machine.
#
# This script only *aggregates and reports* — it never modifies, renames, or
# merges the underlying projects. Each keeps its own identity.
#
# Usage:
#   zero-cost-index.sh                 Full human-readable report
#   zero-cost-index.sh --json          Full machine-readable report
#   zero-cost-index.sh --verified-only Omit the flagged/non-factual section
#   zero-cost-index.sh --path <name>   Print the resolved path for a mode
#                                       (id/slug) or external project (name),
#                                       for use with: cd "$(zero-cost-index.sh --path X)"
#   zero-cost-index.sh -h|--help       Show this help

ZERO_COST_DIR="${ZERO_COST_DIR:-$HOME/.config/zero-cost}"
MODES_DIR="$ZERO_COST_DIR/modes"
REGISTRY_FILE="$ZERO_COST_DIR/external-registry.json"
ACTIVE_POINTER="$ZERO_COST_DIR/active-mode-name.txt"

usage() {
    sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
}

JSON_OUT=0
VERIFIED_ONLY=0
PATH_LOOKUP=""

while [ $# -gt 0 ]; do
    case "$1" in
        --json) JSON_OUT=1; shift ;;
        --verified-only) VERIFIED_ONLY=1; shift ;;
        --path) PATH_LOOKUP="${2:-}"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown argument: %s\n' "$1" >&2; usage >&2; exit 1 ;;
    esac
done

if [ ! -d "$MODES_DIR" ]; then
    printf 'No modes directory found at %s\n' "$MODES_DIR" >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    printf 'python3 is required for zero-cost-index.sh\n' >&2
    exit 1
fi

ACTIVE_FILE=""
if [ -f "$ACTIVE_POINTER" ]; then
    ACTIVE_FILE="$(cat "$ACTIVE_POINTER" 2>/dev/null)"
fi

python3 - "$MODES_DIR" "$REGISTRY_FILE" "$ACTIVE_FILE" "$JSON_OUT" "$VERIFIED_ONLY" "$PATH_LOOKUP" <<'PY'
import glob
import json
import os
import sys

modes_dir, registry_file, active_file, json_out, verified_only, path_lookup = sys.argv[1:7]
json_out = json_out == "1"
verified_only = verified_only == "1"

# --- Load the 30 WARP_ZERO_COST modes ---
modes = []
for path in sorted(glob.glob(os.path.join(modes_dir, "mode-*.sh"))):
    with open(path) as f:
        for line in f:
            if line.startswith("# META:"):
                meta = json.loads(line[len("# META:"):].strip())
                meta["file"] = os.path.basename(path)
                meta["abs_path"] = os.path.abspath(path)
                meta["active"] = meta["file"] == active_file
                modes.append(meta)
                break

# --- Load external registry ---
external = []
if os.path.isfile(registry_file):
    with open(registry_file) as f:
        external = json.load(f)
for e in external:
    resolved = os.path.expanduser(e["path"])
    e["abs_path"] = resolved
    e["exists"] = os.path.exists(resolved)

verified_ext = [e for e in external if e["status"] == "verified"]
flagged_ext = [e for e in external if e["status"] == "flagged"]

# --- --path lookup mode: print exactly one path, nothing else ---
if path_lookup:
    needle = path_lookup.strip().lower()
    for m in modes:
        if needle in (m["id"].lower(), m["slug"].lower(), m["name"].lower()):
            print(m["abs_path"])
            sys.exit(0)
    for e in external:
        if needle in e["name"].lower():
            print(e["abs_path"])
            sys.exit(0)
    print("No match for '%s'" % path_lookup, file=sys.stderr)
    sys.exit(1)

# --- --json mode ---
if json_out:
    out = {
        "warp_zero_cost_modes": modes,
        "external_verified": verified_ext,
    }
    if not verified_only:
        out["external_flagged"] = flagged_ext
    print(json.dumps(out, indent=2))
    sys.exit(0)

# --- Human-readable report ---
def hr(title):
    print("")
    print("=== %s ===" % title)

hr("WARP_ZERO_COST Modes (%d)" % len(modes))
widths = (4, 24, 12, 20, 30)
fmt = "".join("{:%d}" % w for w in widths)
print(fmt.format("ID", "SLUG", "TIER", "SCOPE", "MODEL"))
print(fmt.format(*("-" * (w - 1) for w in widths)))
for m in modes:
    mark = "*" if m["active"] else " "
    model = m["model"] if len(m["model"]) <= 28 else m["model"][:27] + "\u2026"
    print(fmt.format(mark + m["id"], m["slug"], m["tier"], m["scope"], model))

tiers = {}
for m in modes:
    tiers[m["tier"]] = tiers.get(m["tier"], 0) + 1
tier_summary = "  |  ".join("%s: %d" % (k, v) for k, v in sorted(tiers.items()))
print("")
print(tier_summary)
if active_file:
    print("Active mode: %s" % active_file)
else:
    print("Active mode: none (profile.sh defaults apply)")

hr("Other Verified Zero-Cost Projects (%d)" % len(verified_ext))
widths2 = (40, 8, 55)
fmt2 = "".join("{:%d}" % w for w in widths2)
print(fmt2.format("NAME", "EXISTS", "COST NOTE"))
print(fmt2.format(*("-" * (w - 1) for w in widths2)))
for e in verified_ext:
    exists = "yes" if e["exists"] else "MISSING"
    print(fmt2.format(e["name"][:39], exists, e["cost_note"][:54]))
    print("    %s" % e["abs_path"])

if not verified_only:
    hr("Flagged: Not Verified as Factual Zero-Cost (%d)" % len(flagged_ext))
    print(fmt2.format("NAME", "EXISTS", "ISSUE"))
    print(fmt2.format(*("-" * (w - 1) for w in widths2)))
    for e in flagged_ext:
        exists = "yes" if e["exists"] else "MISSING"
        print(fmt2.format(e["name"][:39], exists, e["cost_note"][:54]))
        print("    %s" % e["abs_path"])

hr("Summary")
total = len(modes) + len(verified_ext) + (0 if verified_only else len(flagged_ext))
print("WARP_ZERO_COST modes:      %d (all guaranteed zero Warp credits)" % len(modes))
print("External verified:         %d (independently maintained, zero cost confirmed)" % len(verified_ext))
if not verified_only:
    print("External flagged:          %d (NOT confirmed zero cost - do not rely on these)" % len(flagged_ext))
print("Total indexed:              %d" % total)
print("")
print("Lookup a path:  zero-cost-index.sh --path <id|slug|name>")
print("Activate a mode: source ~/.config/zero-cost/select-mode.sh <id|slug>")
PY
