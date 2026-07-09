#!/bin/bash
set -euo pipefail

echo "=== Commit Federated Alignment Reports ==="
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# --- 1. WARP control repo ---
echo "--- WARP CONTROL REPO ---"
WARP="/Users/billydeeii136/wsd-warp-control"
cd "$WARP"

# Remove generated backup file (not meant to be committed)
rm -f "$WARP/warp-tab-configs/wsd-warp-20.toml.bak.20260606015905"

# Stage all changes including new files
git add -A

if git diff --cached --quiet; then
  echo "[SKIP] WARP repo: nothing to commit"
else
  cat > /tmp/warp-commit-msg <<'MSG'
feat: federated alignment reports and cross-lane workflow

- Add Codex-to-WARP alignment script (scripts/wsd-import-codex-to-warp-align.sh)
- Add federated alignment verification script (scripts/wsd-federated-alignment-verify.sh)
- Add cross-lane federated pulse script (scripts/wsd-cross-lane-federated-pulse.sh)
- Link codex-wsd-control repo via imports/ symlink
- Update warp-tab-configs/wsd-warp-20.toml with ChatGPT 5.5 alignment comment
- Update ARCHITECTURE.md and README.md with latest alignment state
- Add infra-state/infrastructure-state.md with 2026-06-05 alignment
- Update worker src, wrangler.toml, and package for WARP_CONFIG KV binding
- Verify Wrangler dry-run passes with real WARP_CONFIG namespace

Co-Authored-By: Oz <oz-agent@warp.dev>
MSG
  git commit -F /tmp/warp-commit-msg
  echo "[OK] WARP repo committed"

  echo "[INFO] Attempting push to origin/WSD..."
  if git push origin WSD 2>&1; then
    echo "[OK] WARP repo pushed to origin/WSD"
  else
    echo "[WARN] WARP repo push failed (auth/network). Push manually from normal Terminal."
  fi
fi

echo ""

# --- 2. Codex control repo ---
echo "--- CODEX CONTROL REPO ---"
CODEX="/Users/billydeeii136/codex-wsd-control"
cd "$CODEX"

# Stage all changes including new files
git add -A

if git diff --cached --quiet; then
  echo "[SKIP] Codex repo: nothing to commit"
else
  cat > /tmp/codex-commit-msg <<'MSG'
feat: federated alignment and cross-lane shared-brain coordination

- Codex memory synced to WARP lane via symlinks
- Federated alignment rule embedded in AGENTS.md and STATE.md
- Shared-brain agent coordination updated for ChatGPT 5.5 / WARP / Terminal
- Cross-lane workflow scripts and verification added via WARP repo
- Alignment manifest generated and linked across all lane memories

Co-Authored-By: Oz <oz-agent@warp.dev>
MSG
  git commit -F /tmp/codex-commit-msg
  echo "[OK] Codex repo committed"

  echo "[INFO] Attempting push to origin/main..."
  if git push origin main 2>&1; then
    echo "[OK] Codex repo pushed to origin/main"
  else
    echo "[WARN] Codex repo push failed (auth/network). Push manually from normal Terminal."
  fi
fi

echo ""
echo "========================================"
echo "  COMMIT OPERATION COMPLETE"
echo "========================================"
