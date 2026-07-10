#!/bin/bash
# META: {"id": "04", "slug": "ollama-lightweight", "name": "Ollama Lightweight", "tier": "local-free", "scope": "localhost", "model": "phi3", "desc": "Small/fast model for low-power hardware (Phi-3)"}
# Ollama Lightweight (local-free)
# Small/fast model for low-power hardware (Phi-3)
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 04

export ZERO_COST_ACTIVE_MODE_ID="04"
export ZERO_COST_ACTIVE_MODE_SLUG="ollama-lightweight"
export ZERO_COST_ACTIVE_MODE_NAME="Ollama Lightweight"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="phi3"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"
export OPENAI_API_KEY="ollama"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
