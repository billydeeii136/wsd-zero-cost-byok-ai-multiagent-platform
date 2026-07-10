#!/bin/bash
# META: {"id": "25", "slug": "mistral-byok", "name": "Mistral La Plateforme (BYOK)", "tier": "byok-remote", "scope": "remote", "model": "mistral-large-latest", "desc": "Mistral's own hosted API"}
# Mistral La Plateforme (BYOK) (byok-remote)
# Mistral's own hosted API
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 25

export ZERO_COST_ACTIVE_MODE_ID="25"
export ZERO_COST_ACTIVE_MODE_SLUG="mistral-byok"
export ZERO_COST_ACTIVE_MODE_NAME="Mistral La Plateforme (BYOK)"
export ZERO_COST_ACTIVE_MODE_TIER="byok-remote"
export ZERO_COST_ACTIVE_MODE_SCOPE="remote"
export ZERO_COST_DEFAULT_MODEL="mistral-large-latest"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="https://api.mistral.ai/v1"
export OPENAI_API_KEY="${MISTRAL_API_KEY:-}"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=1
if [ -z "$OPENAI_API_KEY" ]; then
    printf '[zero-cost] Warning: MISTRAL_API_KEY is not set. Add it to ~/.warp/byok-key-inventory.env\n' >&2
fi

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
