#!/bin/bash
# META: {"id": "22", "slug": "groq-byok", "name": "Groq (BYOK)", "tier": "byok-remote", "scope": "remote", "model": "llama-3.3-70b-versatile", "desc": "Groq ultra-fast inference, generous free tier"}
# Groq (BYOK) (byok-remote)
# Groq ultra-fast inference, generous free tier
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 22

export ZERO_COST_ACTIVE_MODE_ID="22"
export ZERO_COST_ACTIVE_MODE_SLUG="groq-byok"
export ZERO_COST_ACTIVE_MODE_NAME="Groq (BYOK)"
export ZERO_COST_ACTIVE_MODE_TIER="byok-remote"
export ZERO_COST_ACTIVE_MODE_SCOPE="remote"
export ZERO_COST_DEFAULT_MODEL="llama-3.3-70b-versatile"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="https://api.groq.com/openai/v1"
export OPENAI_API_KEY="${GROQ_API_KEY:-}"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=1
if [ -z "$OPENAI_API_KEY" ]; then
    printf '[zero-cost] Warning: GROQ_API_KEY is not set. Add it to ~/.warp/byok-key-inventory.env\n' >&2
fi

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
