#!/bin/bash
set -euo pipefail

echo "=== WSD Codex-to-WARP Alignment Script ==="
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "User: $(whoami)"
echo "Shell: $SHELL"
echo ""

# --- Paths ---
CODEX_REPO="/Users/billydeeii136/codex-wsd-control"
WARP_REPO="/Users/billydeeii136/wsd-warp-control"
WARP_LANE="/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/warp/projects/wsd-warp-ai-orchestrator/lanes/warp"
CHATGPT_LANE="/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/openai-chatgpt/projects/wsd-shared-brain/lanes/chatgpt"
WARP_TAB_CONFIG="$WARP_REPO/warp-tab-configs/wsd-warp-20.toml"

# --- 1. Validate source paths ---
if [ ! -d "$CODEX_REPO" ]; then
  echo "ERROR: Codex repo not found at $CODEX_REPO"
  exit 1
fi
if [ ! -d "$WARP_REPO" ]; then
  echo "ERROR: WARP repo not found at $WARP_REPO"
  exit 1
fi

# --- 2. Ensure WARP lane directories exist ---
mkdir -p "$WARP_LANE/memory"
mkdir -p "$WARP_LANE/work"
mkdir -p "$WARP_LANE/logs"
mkdir -p "$WARP_LANE/tmp"
echo "[OK] WARP lane directories ensured: $WARP_LANE"

# --- 3. Sync Codex canonical memory into WARP lane memory (symlinks, no duplication) ---
WARP_MEM="$WARP_LANE/memory"

# Clean old codex symlinks to avoid stale links
find "$WARP_MEM" -maxdepth 1 -type l \( \
  -name "codex-CODEX_MEMORY_BOOTSTRAP.md" \
  -o -name "codex-STATE.md" \
  -o -name "codex-NEXT-ACTIONS.md" \
  -o -name "codex-AGENTS.md" \
  -o -name "codex-SHARED-BRAIN-AGENT-COORDINATION.md" \
  -o -name "codex-warp-alignment-manifest.md" \
\) -delete 2>/dev/null || true

for file in CODEX_MEMORY_BOOTSTRAP.md STATE.md NEXT-ACTIONS.md AGENTS.md SHARED-BRAIN-AGENT-COORDINATION.md; do
  src="$CODEX_REPO/$file"
  dst="$WARP_MEM/codex-$file"
  if [ -f "$src" ]; then
    ln -sf "$src" "$dst"
    echo "[OK] Linked codex-$file"
  else
    echo "[WARN] Missing: $src"
  fi
done

# --- 4. Write alignment manifest ---
cat > "$WARP_MEM/codex-warp-alignment-manifest.md" <<EOF
# Codex-to-WARP Alignment Manifest

**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)  
**Status:** active  
**Alignment target:** ChatGPT 5.5 / Codex / WARP shared-brain coordination

## Source of Truth
- Codex Repo: \`$CODEX_REPO\`
- WARP Lane: \`$WARP_LANE\`
- WARP Control Repo: \`$WARP_REPO\`

## Synced Memory Files
| File | Purpose |
|---|---|
| codex-CODEX_MEMORY_BOOTSTRAP.md | Session-start bootstrap |
| codex-STATE.md | Persistent state |
| codex-NEXT-ACTIONS.md | Action tracker |
| codex-AGENTS.md | Agent rules |
| codex-SHARED-BRAIN-AGENT-COORDINATION.md | Cross-lane coordination |

## ChatGPT 5.5 Lane
- **Current:** \`$CHATGPT_LANE\`
- **Compatibility:** \`/Users/billydeeii136/WSD_AI_AGENT_LANES/chatgpt\`

## WARP Worker
- Path: \`$WARP_REPO/worker\`
- KV Binding: \`WARP_CONFIG\`
- Route: \`warp.wsdenterprisesworldwide.com\`

## Federated Alignment Rule
No single agent is the sole command authority. Codex, WARP, Terminal, and ChatGPT 5.5 are equal participants.
EOF
echo "[OK] Wrote alignment manifest: $WARP_MEM/codex-warp-alignment-manifest.md"

# --- 5. Ensure WARP repo imports Codex by reference ---
mkdir -p "$WARP_REPO/imports"
if [ ! -L "$WARP_REPO/imports/codex-wsd-control" ]; then
  ln -sf "$CODEX_REPO" "$WARP_REPO/imports/codex-wsd-control"
  echo "[OK] Linked codex repo into WARP imports/"
else
  echo "[OK] Codex repo link already present in WARP imports/"
fi

# --- 6. Update WARP tab config (backup + append alignment comment) ---
if [ -f "$WARP_TAB_CONFIG" ]; then
  BACKUP="$WARP_TAB_CONFIG.bak.$(date -u +%Y%m%d%H%M%S)"
  cp "$WARP_TAB_CONFIG" "$BACKUP"
  echo "[OK] Backed up tab config -> $(basename $BACKUP)"

  if ! grep -q "ChatGPT 5.5 Alignment" "$WARP_TAB_CONFIG"; then
    cat >> "$WARP_TAB_CONFIG" <<EOF

# --- ChatGPT 5.5 Alignment ---
# Lane: /Users/billydeeii136/WSD_AI_AGENT_LANES/programs/openai-chatgpt/projects/wsd-shared-brain/lanes/chatgpt
# Compatibility: /Users/billydeeii136/WSD_AI_AGENT_LANES/chatgpt
# Codex memory synced into WARP lane memory at: $WARP_LANE/memory
# Manifest: $WARP_MEM/codex-warp-alignment-manifest.md
# ---
EOF
    echo "[OK] Appended ChatGPT 5.5 alignment comment to tab config"
  else
    echo "[OK] Tab config already contains ChatGPT 5.5 alignment comment"
  fi
else
  echo "[WARN] WARP tab config not found at $WARP_TAB_CONFIG"
fi

# --- 7. WARP Worker validation ---
WORKER_DIR="$WARP_REPO/worker"
if [ -d "$WORKER_DIR" ]; then
  cd "$WORKER_DIR"

  echo ""
  echo "[STEP] WARP Worker typecheck..."
  if [ -f "scripts/typecheck.mjs" ]; then
    if node scripts/typecheck.mjs; then
      echo "[PASS] Typecheck OK"
    else
      echo "[WARN] Typecheck returned non-zero (may be network/tsc absence; fallback dry-run next)"
    fi
  else
    echo "[SKIP] scripts/typecheck.mjs not found"
  fi

  echo ""
  echo "[STEP] WARP Worker dry-run (Wrangler)..."
  if command -v wrangler >/dev/null 2>&1; then
    # Dry-run only; do not deploy. Capture output.
    if wrangler deploy --dry-run 2>&1; then
      echo "[PASS] Wrangler dry-run OK"
    else
      echo "[WARN] Wrangler dry-run failed (auth/network/account issue). This is non-fatal for alignment."
      echo "       Run 'key-token-status' and 'wrangler deploy --dry-run' from normal Terminal if needed."
    fi
  else
    echo "[SKIP] wrangler not in PATH"
  fi
else
  echo "[WARN] Worker directory not found at $WORKER_DIR"
fi

# --- 8. Print summary ---
echo ""
echo "========================================"
echo "  Codex-to-WARP Alignment Complete"
echo "========================================"
echo "WARP Lane Memory : $WARP_LANE/memory"
echo "WARP Tab Config  : $WARP_TAB_CONFIG"
echo "ChatGPT 5.5 Lane : $CHATGPT_LANE"
echo "Codex Repo       : $CODEX_REPO"
echo "WARP Control     : $WARP_REPO"
echo ""
echo "Next steps from normal Terminal:"
echo "  key-token-status"
echo "  wrangler deploy --dry-run"
echo "  wrangler deploy      (when ready to push live)"
echo ""
