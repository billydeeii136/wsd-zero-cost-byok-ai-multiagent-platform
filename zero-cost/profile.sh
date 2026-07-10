#!/bin/bash
# Local-first zero-cost defaults for OpenAI-compatible tools/connectors.

export ZERO_COST_MODE=1
export ZERO_COST_PROFILE_VERSION="2026-07-07"

# Force OpenAI-compatible routing to the local Ollama endpoint unless explicitly allowed.
if [ "${ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT:-0}" != "1" ]; then
    export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"
    export OPENAI_API_KEY="ollama"
else
    export OPENAI_API_KEY="${OPENAI_API_KEY:-ollama}"
fi

# Safe non-secret defaults for local OpenAI-compatible clients.
export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"

# Compatibility variables used by wrappers/connectors.
export LLM_BASE_URL="${LLM_BASE_URL:-$OPENAI_BASE_URL}"
export LLM_API_KEY="${LLM_API_KEY:-$OPENAI_API_KEY}"
export ZERO_COST_FORCE_LOCAL_OPENAI_COMPAT=1

# Re-apply critical Warp zero-credit settings in case Warp rewrites settings.toml.
if [ -x "$HOME/.config/zero-cost/warp-guard.sh" ]; then
    "$HOME/.config/zero-cost/warp-guard.sh" >/dev/null 2>&1 || true
fi
