#!/bin/bash
# WARP Cloud Agent Workaround — All-in-One Fix Script
# Fixes common issues: Python, Docker image, agent limits, directory access

set -euo pipefail

ENV_ID="EJInLBQZTYgFMpsfxqwYPf"
REPO="/Users/billydeeii136/wsd-warp-control"

echo "=== WARP Cloud Agent Workaround ==="
echo "Checking environment and fixing common issues..."
echo

# --- Fix 1: Python symlink (python -> python3) ---
if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
    echo "[FIX] 'python' missing but 'python3' found. Creating symlink..."
    sudo ln -sf "$(which python3)" /usr/local/bin/python
    echo "[OK] Symlink created: python -> $(which python3)"
else
    echo "[OK] Python is available: $(python --version 2>/dev/null || python3 --version 2>/dev/null || echo 'unknown')"
fi

# --- Fix 2: Validate and repair Docker image in environment ---
ENV_JSON=$(oz environment get "$ENV_ID" --output-format json 2>/dev/null || echo '{}')
DOCKER_IMG=$(echo "$ENV_JSON" | grep -o '"docker_image":"[^"]*"' | cut -d'"' -f4 || echo '')

if [[ -z "$DOCKER_IMG" ]] || [[ "$DOCKER_IMG" != "python:3.11" ]]; then
    echo "[FIX] Invalid Docker image detected: '$DOCKER_IMG'. Updating to python:3.11..."
    oz environment update "$ENV_ID" -d python:3.11
    echo "[OK] Docker image updated to python:3.11"
else
    echo "[OK] Docker image is valid: $DOCKER_IMG"
fi

# --- Fix 3: Ensure at least one agent profile exists (workaround for 1-agent limit) ---
AGENT_LIST=$(oz agent list --output-format json 2>/dev/null || echo '[]')
AGENT_COUNT=$(echo "$AGENT_LIST" | grep -c '"uid"' || echo 0)

if [[ "$AGENT_COUNT" -eq 0 ]]; then
    echo "[FIX] No agent profiles found. Creating 'priya' (first pane name)..."
    oz agent create --name priya --description "Cloud agent for WARP tab pane priya" --environment "$ENV_ID"
    echo "[OK] Created agent profile: priya"
else
    echo "[OK] Found $AGENT_COUNT agent profile(s). Using existing for runs."
fi

echo
echo "=== Quick Commands ==="
echo "Run cloud agent (uses single profile, names via --name flag):"
echo "  oz agent run-cloud --name PANE_NAME --environment $ENV_ID --prompt \"Your task\""
echo
echo "Test cloud agent:"
echo "  oz agent run-cloud --name priya --environment $ENV_ID --prompt \"Echo test successful\""
echo
echo "Add a repo to the environment (so cloud agents can access code):"
echo "  oz environment update $ENV_ID -r owner/repo"
echo
echo "List recent runs:"
echo "  oz run list --limit 5"
echo
echo "=== Important Notes ==="
echo "1. CLOUD SANDBOX ISOLATION: Your Mac dirs (/Users/...) are NOT accessible from cloud agents."
echo "   - Use Git repos in the environment, or run Wrangler/Tunnel commands locally."
echo "2. AGENT PROFILE LIMIT: Your plan supports 1 persistent agent profile."
echo "   - Use --name flag per run to label different pane work."
echo "3. PYTHON: Always use 'python3' or ensure the 'python' symlink exists."
echo "4. DOCKER IMAGE: Must be a valid Docker reference (e.g., python:3.11), not 'Python 3.11.'"
echo
echo "All fixes applied. Environment is ready for cloud agent runs."
