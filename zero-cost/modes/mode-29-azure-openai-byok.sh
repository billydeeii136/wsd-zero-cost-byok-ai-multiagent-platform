#!/bin/bash
# META: {"id": "29", "slug": "azure-openai-byok", "name": "Azure OpenAI (BYOK Enterprise)", "tier": "byok-remote", "scope": "remote", "model": "(Azure deployment-defined)", "desc": "Azure OpenAI enterprise BYOK routing"}
# Azure OpenAI (BYOK Enterprise) (byok-remote)
# Azure OpenAI enterprise BYOK routing
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 29

export ZERO_COST_ACTIVE_MODE_ID="29"
export ZERO_COST_ACTIVE_MODE_SLUG="azure-openai-byok"
export ZERO_COST_ACTIVE_MODE_NAME="Azure OpenAI (BYOK Enterprise)"
export ZERO_COST_ACTIVE_MODE_TIER="byok-remote"
export ZERO_COST_ACTIVE_MODE_SCOPE="remote"
export ZERO_COST_DEFAULT_MODEL="(Azure deployment-defined)"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="https://${AZURE_OPENAI_RESOURCE}.openai.azure.com/openai/deployments/${AZURE_OPENAI_DEPLOYMENT}"
export OPENAI_API_KEY="${AZURE_OPENAI_API_KEY:-}"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=1
if [ -z "$OPENAI_API_KEY" ]; then
    printf '[zero-cost] Warning: AZURE_OPENAI_API_KEY is not set. Add it to ~/.warp/byok-key-inventory.env\n' >&2
fi

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
