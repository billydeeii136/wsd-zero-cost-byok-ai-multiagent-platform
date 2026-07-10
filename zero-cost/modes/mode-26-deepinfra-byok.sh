#!/bin/bash
# META: {"id": "26", "slug": "deepinfra-byok", "name": "DeepInfra (BYOK)", "tier": "byok-remote", "scope": "remote", "model": "meta-llama/Meta-Llama-3.1-70B-Instruct", "desc": "DeepInfra hosted open-weight models"}
# DeepInfra (BYOK) (byok-remote)
# DeepInfra hosted open-weight models
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 26

export ZERO_COST_ACTIVE_MODE_ID="26"
export ZERO_COST_ACTIVE_MODE_SLUG="deepinfra-byok"
export ZERO_COST_ACTIVE_MODE_NAME="DeepInfra (BYOK)"
export ZERO_COST_ACTIVE_MODE_TIER="byok-remote"
export ZERO_COST_ACTIVE_MODE_SCOPE="remote"
export ZERO_COST_DEFAULT_MODEL="meta-llama/Meta-Llama-3.1-70B-Instruct"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="https://api.deepinfra.com/v1/openai"
export OPENAI_API_KEY="${DEEPINFRA_API_KEY:-}"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=1
if [ -z "$OPENAI_API_KEY" ]; then
    printf '[zero-cost] Warning: DEEPINFRA_API_KEY is not set. Add it to ~/.warp/byok-key-inventory.env\n' >&2
fi

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
