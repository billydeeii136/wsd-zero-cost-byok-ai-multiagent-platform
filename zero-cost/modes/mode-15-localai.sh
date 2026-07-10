#!/bin/bash
# META: {"id": "15", "slug": "localai", "name": "LocalAI", "tier": "local-free", "scope": "localhost", "model": "(model configured in LocalAI)", "desc": "LocalAI self-hosted OpenAI-compatible server"}
# LocalAI (local-free)
# LocalAI self-hosted OpenAI-compatible server
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 15

export ZERO_COST_ACTIVE_MODE_ID="15"
export ZERO_COST_ACTIVE_MODE_SLUG="localai"
export ZERO_COST_ACTIVE_MODE_NAME="LocalAI"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="(model configured in LocalAI)"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:8081/v1"
export OPENAI_API_KEY="localai"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
