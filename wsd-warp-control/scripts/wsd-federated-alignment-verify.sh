#!/bin/bash
set -euo pipefail

echo "=== WSD Federated Alignment Cross-Lane Verification ==="
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

REPORT="/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/warp/projects/wsd-warp-ai-orchestrator/lanes/warp/logs/federated-alignment-verify-$(date -u +%Y%m%dT%H%M%SZ).md"
mkdir -p "$(dirname "$REPORT")"

exec > >(tee -a "$REPORT")
exec 2>&1

PASS=0
WARN=0
FAIL=0

pass() { echo "[PASS] $1"; PASS=$((PASS+1)); }
warn() { echo "[WARN] $1"; WARN=$((WARN+1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL+1)); }

# --- Lane 1: Terminal / Bash Preload ---
echo ""
echo "--- LANE 1: TERMINAL / BASH ---"

if [ "$SHELL" = "/bin/bash" ]; then pass "Shell is /bin/bash"; else warn "Shell is $SHELL (expected /bin/bash)"; fi
if [ "$(basename "$(pwd)")" = "billydeeii136" ]; then pass "CWD is home directory"; else warn "CWD is $(pwd)"; fi

if echo "$PATH" | grep -q "/Users/billydeeii136/.npm-global/bin"; then pass "PATH includes .npm-global/bin"; else warn "PATH missing .npm-global/bin"; fi

if [ -f "/Users/billydeeii136/.wsd-bash-preload.sh" ]; then pass "Bash preload exists"; else warn "Bash preload missing"; fi

if [ -n "${WSD_TERMINAL_PATH_READY:-}" ]; then pass "WSD_TERMINAL_PATH_READY set"; else warn "WSD_TERMINAL_PATH_READY unset"; fi
if [ -n "${WSD_TERMINAL_DIRECTORY_READY:-}" ]; then pass "WSD_TERMINAL_DIRECTORY_READY set"; else warn "WSD_TERMINAL_DIRECTORY_READY unset"; fi

if command -v codex >/dev/null 2>&1; then pass "codex CLI in PATH"; else warn "codex CLI not in PATH"; fi
if command -v wrangler >/dev/null 2>&1; then pass "wrangler in PATH"; else warn "wrangler not in PATH"; fi
if command -v gh >/dev/null 2>&1; then pass "gh in PATH"; else warn "gh not in PATH"; fi
if command -v git >/dev/null 2>&1; then pass "git in PATH"; else warn "git not in PATH"; fi
if command -v ssh-add >/dev/null 2>&1; then pass "ssh-add in PATH"; else warn "ssh-add not in PATH"; fi
if command -v node >/dev/null 2>&1; then pass "node in PATH"; else warn "node not in PATH"; fi
if command -v npm >/dev/null 2>&1; then pass "npm in PATH"; else warn "npm not in PATH"; fi

# --- Lane 2: Codex Repo ---
echo ""
echo "--- LANE 2: CODEX REPO ---"

CODEX="/Users/billydeeii136/codex-wsd-control"
if [ -d "$CODEX" ]; then pass "Codex repo directory exists"; else fail "Codex repo missing"; fi

for f in CODEX_MEMORY_BOOTSTRAP.md STATE.md NEXT-ACTIONS.md AGENTS.md SHARED-BRAIN-AGENT-COORDINATION.md; do
  if [ -f "$CODEX/$f" ]; then pass "Codex file $f present"; else warn "Codex file $f missing"; fi
done

if grep -q "Federated Alignment Rule" "$CODEX/AGENTS.md" 2>/dev/null; then pass "Federated alignment rule in AGENTS.md"; else warn "Federated alignment rule missing in AGENTS.md"; fi

# --- Lane 3: WARP Control ---
echo ""
echo "--- LANE 3: WARP CONTROL ---"

WARP="/Users/billydeeii136/wsd-warp-control"
if [ -d "$WARP" ]; then pass "WARP control repo exists"; else fail "WARP control repo missing"; fi
if [ -f "$WARP/warp-tab-configs/wsd-warp-20.toml" ]; then pass "WARP 20-pane tab config exists"; else warn "WARP tab config missing"; fi
if [ -f "$WARP/worker/src/index.ts" ]; then pass "WARP Worker source exists"; else warn "WARP Worker source missing"; fi
if [ -f "$WARP/worker/wrangler.toml" ]; then pass "WARP wrangler.toml exists"; else warn "WARP wrangler.toml missing"; fi

if [ -L "$WARP/imports/codex-wsd-control" ]; then
  pass "WARP imports codex-wsd-control symlink exists"
else
  warn "WARP imports codex-wsd-control symlink missing"
fi

if grep -q "ChatGPT 5.5 Alignment" "$WARP/warp-tab-configs/wsd-warp-20.toml" 2>/dev/null; then
  pass "Tab config contains ChatGPT 5.5 alignment comment"
else
  warn "Tab config missing ChatGPT 5.5 alignment comment"
fi

# WARP Worker dry-run (non-deploying)
if [ -d "$WARP/worker" ]; then
  cd "$WARP/worker"
  if wrangler deploy --dry-run 2>&1 | grep -q "dry-run: exiting now"; then
    pass "WARP Worker wrangler dry-run passes"
  else
    warn "WARP Worker wrangler dry-run did not report clean exit"
  fi
  cd - >/dev/null
else
  warn "Cannot run WARP Worker dry-run (missing directory)"
fi

# --- Lane 4: WARP Lane Memory ---
echo ""
echo "--- LANE 4: WARP LANE MEMORY ---"

WARP_MEM="/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/warp/projects/wsd-warp-ai-orchestrator/lanes/warp/memory"
if [ -d "$WARP_MEM" ]; then pass "WARP lane memory directory exists"; else warn "WARP lane memory missing"; fi

for f in codex-CODEX_MEMORY_BOOTSTRAP.md codex-STATE.md codex-NEXT-ACTIONS.md codex-AGENTS.md codex-SHARED-BRAIN-AGENT-COORDINATION.md; do
  if [ -L "$WARP_MEM/$f" ]; then
    if [ -f "$WARP_MEM/$f" ]; then
      pass "WARP memory symlink $f active and readable"
    else
      warn "WARP memory symlink $f broken (target missing)"
    fi
  else
    warn "WARP memory symlink $f missing"
  fi
done

if [ -f "$WARP_MEM/codex-warp-alignment-manifest.md" ]; then
  pass "Codex-to-WARP alignment manifest present"
else
  warn "Codex-to-WARP alignment manifest missing"
fi

# --- Lane 5: ChatGPT 5.5 ---
echo ""
echo "--- LANE 5: CHATGPT 5.5 ---"

CHATGPT="/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/openai-chatgpt/projects/wsd-shared-brain/lanes/chatgpt"
if [ -d "$CHATGPT" ]; then pass "ChatGPT 5.5 lane directory exists"; else warn "ChatGPT 5.5 lane directory missing"; fi
if [ -d "$CHATGPT/memory" ]; then pass "ChatGPT 5.5 lane memory directory exists"; else warn "ChatGPT 5.5 lane memory missing"; fi

if command -v chatgpt >/dev/null 2>&1; then
  pass "chatgpt CLI in PATH"
  if chatgpt --version >/dev/null 2>&1; then pass "chatgpt --version runs"; else warn "chatgpt --version failed"; fi
  if chatgpt --model >/dev/null 2>&1; then pass "chatgpt --model runs"; else warn "chatgpt --model failed"; fi
  if chatgpt --status >/dev/null 2>&1; then pass "chatgpt --status runs"; else warn "chatgpt --status failed"; fi
else
  warn "chatgpt CLI not in PATH"
fi

# --- Lane 6: Shared Brain / Program-Project-Lane ---
echo ""
echo "--- LANE 6: SHARED-BRAIN / PPL STRUCTURE ---"

if [ -d "/Users/billydeeii136/WSD_AI_AGENT_LANES/programs" ]; then pass "Programs directory exists"; else warn "Programs directory missing"; fi
if [ -d "/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/warp" ]; then pass "WARP program exists"; else warn "WARP program missing"; fi
if [ -d "/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/warp/projects/wsd-warp-ai-orchestrator" ]; then pass "WARP project exists"; else warn "WARP project missing"; fi
if [ -d "/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/warp/projects/wsd-warp-ai-orchestrator/lanes/warp" ]; then pass "WARP lane exists"; else warn "WARP lane missing"; fi

if [ -d "/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/openai-chatgpt" ]; then pass "ChatGPT program exists"; else warn "ChatGPT program missing"; fi

# --- Lane 7: Auth / Keychain Status (name-only, no secrets) ---
echo ""
echo "--- LANE 7: AUTH / KEYCHAIN STATUS (names only) ---"

if command -v key-token-status >/dev/null 2>&1; then
  pass "key-token-status wrapper in PATH"
  # Run but suppress any raw values; we only want to know if the tool runs
  if key-token-status 2>&1 | grep -q "CLOUDFLARE_ACCOUNT_ID"; then
    pass "key-token-status reports Cloudflare account status"
  else
    warn "key-token-status missing Cloudflare account info"
  fi
else
  warn "key-token-status not in PATH"
fi

if ssh-add -l >/dev/null 2>&1; then
  KEY_COUNT=$(ssh-add -l 2>/dev/null | wc -l | tr -d ' ')
  pass "SSH agent active with $KEY_COUNT key(s)"
else
  warn "SSH agent not active or no keys loaded"
fi

if gh auth status 2>&1 | grep -q "Logged in to github.com"; then
  pass "GitHub CLI authenticated"
else
  warn "GitHub CLI not authenticated (may need normal Terminal re-auth)"
fi

# --- Summary ---
echo ""
echo "========================================"
echo "  FEDERATED ALIGNMENT VERIFICATION"
echo "========================================"
echo "PASS: $PASS"
echo "WARN: $WARN"
echo "FAIL: $FAIL"
echo ""
echo "Report written: $REPORT"
echo ""

if [ $FAIL -eq 0 ]; then
  echo "OVERALL: FEDERATED ALIGNMENT VERIFIED"
else
  echo "OVERALL: ISSUES DETECTED — REVIEW WARN/FAIL LINES ABOVE"
fi
