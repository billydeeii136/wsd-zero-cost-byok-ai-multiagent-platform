#!/bin/bash
# META: {"id": "20", "slug": "ollama-airgapped-strict", "name": "Ollama Airgapped Strict", "tier": "local-free", "scope": "localhost-strict", "model": "llama3.2", "desc": "Strict loopback-only; remote BYOK explicitly disabled at the mode level"}
# Ollama Airgapped Strict (local-free)
# Strict loopback-only; remote BYOK explicitly disabled at the mode level
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 20

export ZERO_COST_ACTIVE_MODE_ID="20"
export ZERO_COST_ACTIVE_MODE_SLUG="ollama-airgapped-strict"
export ZERO_COST_ACTIVE_MODE_NAME="Ollama Airgapped Strict"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost-strict"
export ZERO_COST_DEFAULT_MODEL="llama3.2"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"
export OPENAI_API_KEY="ollama"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
