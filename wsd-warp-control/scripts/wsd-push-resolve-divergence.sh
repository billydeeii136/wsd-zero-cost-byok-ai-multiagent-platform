#!/bin/bash
set -euo pipefail

echo "=== Resolve Divergence and Push Federated Alignment Commits ==="
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# --- WARP repo ---
echo "--- WARP CONTROL REPO ---"
WARP="/Users/billydeeii136/wsd-warp-control"
cd "$WARP"

# Show current state
echo "Local HEAD: $(git rev-parse --short HEAD)"
echo "Remote HEAD: $(git rev-parse --short origin/WSD)"

# Fetch and rebase onto remote
git fetch origin WSD
git pull --rebase origin WSD 2>&1 || {
  echo "[WARN] WARP rebase failed; attempting merge instead..."
  git merge origin/WSD --no-edit 2>&1 || {
    echo "[FAIL] WARP merge failed. Manual resolution required."
    exit 1
  }
}

if git push origin WSD 2>&1; then
  echo "[OK] WARP repo pushed to origin/WSD"
else
  echo "[WARN] WARP repo push still failed. Check manually."
fi

echo ""

# --- Codex repo ---
echo "--- CODEX CONTROL REPO ---"
CODEX="/Users/billydeeii136/codex-wsd-control"
cd "$CODEX"

echo "Local HEAD: $(git rev-parse --short HEAD)"
echo "Remote HEAD: $(git rev-parse --short origin/main)"

# Fetch and rebase onto remote
git fetch origin main
git pull --rebase origin main 2>&1 || {
  echo "[WARN] Codex rebase failed; attempting merge instead..."
  git merge origin/main --no-edit 2>&1 || {
    echo "[FAIL] Codex merge failed. Manual resolution required."
    exit 1
  }
}

if git push origin main 2>&1; then
  echo "[OK] Codex repo pushed to origin/main"
else
  echo "[WARN] Codex repo push still failed. Check manually."
fi

echo ""
echo "========================================"
echo "  PUSH OPERATION COMPLETE"
echo "========================================"
