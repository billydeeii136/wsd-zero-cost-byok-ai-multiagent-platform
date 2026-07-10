#!/bin/bash
# META: {"id": "11", "slug": "lmstudio-local", "name": "LM Studio Local", "tier": "local-free", "scope": "localhost", "model": "(model loaded in LM Studio GUI)", "desc": "LM Studio local server, GUI-managed model selection"}
# LM Studio Local (local-free)
# LM Studio local server, GUI-managed model selection
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 11

export ZERO_COST_ACTIVE_MODE_ID="11"
export ZERO_COST_ACTIVE_MODE_SLUG="lmstudio-local"
export ZERO_COST_ACTIVE_MODE_NAME="LM Studio Local"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="(model loaded in LM Studio GUI)"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:1234/v1"
export OPENAI_API_KEY="lm-studio"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
