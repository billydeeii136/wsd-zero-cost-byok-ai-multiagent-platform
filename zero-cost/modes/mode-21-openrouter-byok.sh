#!/bin/bash
# META: {"id": "21", "slug": "openrouter-byok", "name": "OpenRouter (BYOK)", "tier": "byok-remote", "scope": "remote", "model": "meta-llama/llama-3.1-70b-instruct", "desc": "OpenRouter multi-provider model gateway"}
# OpenRouter (BYOK) (byok-remote)
# OpenRouter multi-provider model gateway
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 21

export ZERO_COST_ACTIVE_MODE_ID="21"
export ZERO_COST_ACTIVE_MODE_SLUG="openrouter-byok"
export ZERO_COST_ACTIVE_MODE_NAME="OpenRouter (BYOK)"
export ZERO_COST_ACTIVE_MODE_TIER="byok-remote"
export ZERO_COST_ACTIVE_MODE_SCOPE="remote"
export ZERO_COST_DEFAULT_MODEL="meta-llama/llama-3.1-70b-instruct"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
export OPENAI_API_KEY="${OPENROUTER_API_KEY:-}"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=1
if [ -z "$OPENAI_API_KEY" ]; then
    printf '[zero-cost] Warning: OPENROUTER_API_KEY is not set. Add it to ~/.warp/byok-key-inventory.env\n' >&2
fi

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
