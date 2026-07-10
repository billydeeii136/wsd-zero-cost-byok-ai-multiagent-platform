#!/bin/bash
# META: {"id": "19", "slug": "ollama-lan-wide", "name": "Ollama LAN-Wide", "tier": "local-free", "scope": "lan", "model": "llama3.2", "desc": "Ollama bound to 0.0.0.0, reachable by other WSD home network nodes"}
# Ollama LAN-Wide (local-free)
# Ollama bound to 0.0.0.0, reachable by other WSD home network nodes
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 19

export ZERO_COST_ACTIVE_MODE_ID="19"
export ZERO_COST_ACTIVE_MODE_SLUG="ollama-lan-wide"
export ZERO_COST_ACTIVE_MODE_NAME="Ollama LAN-Wide"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="lan"
export ZERO_COST_DEFAULT_MODEL="llama3.2"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://0.0.0.0:11434/v1"
export OPENAI_API_KEY="ollama"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0
# NOTE: this only changes where CLIENTS connect. To actually bind the Ollama
# server to the LAN, start it with: OLLAMA_HOST=0.0.0.0:11434 ollama serve

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
