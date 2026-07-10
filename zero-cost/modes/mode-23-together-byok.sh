#!/bin/bash
# META: {"id": "23", "slug": "together-byok", "name": "Together.ai (BYOK)", "tier": "byok-remote", "scope": "remote", "model": "meta-llama/Llama-3-70b-chat-hf", "desc": "Together.ai hosted open-weight models"}
# Together.ai (BYOK) (byok-remote)
# Together.ai hosted open-weight models
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 23

export ZERO_COST_ACTIVE_MODE_ID="23"
export ZERO_COST_ACTIVE_MODE_SLUG="together-byok"
export ZERO_COST_ACTIVE_MODE_NAME="Together.ai (BYOK)"
export ZERO_COST_ACTIVE_MODE_TIER="byok-remote"
export ZERO_COST_ACTIVE_MODE_SCOPE="remote"
export ZERO_COST_DEFAULT_MODEL="meta-llama/Llama-3-70b-chat-hf"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="https://api.together.xyz/v1"
export OPENAI_API_KEY="${TOGETHER_API_KEY:-}"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=1
if [ -z "$OPENAI_API_KEY" ]; then
    printf '[zero-cost] Warning: TOGETHER_API_KEY is not set. Add it to ~/.warp/byok-key-inventory.env\n' >&2
fi

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
