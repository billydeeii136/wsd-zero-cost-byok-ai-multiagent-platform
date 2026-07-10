#!/bin/bash
# META: {"id": "05", "slug": "ollama-deepseek-coder", "name": "Ollama DeepSeek Coder", "tier": "local-free", "scope": "localhost", "model": "deepseek-coder-v2", "desc": "DeepSeek Coder V2 local model"}
# Ollama DeepSeek Coder (local-free)
# DeepSeek Coder V2 local model
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 05

export ZERO_COST_ACTIVE_MODE_ID="05"
export ZERO_COST_ACTIVE_MODE_SLUG="ollama-deepseek-coder"
export ZERO_COST_ACTIVE_MODE_NAME="Ollama DeepSeek Coder"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="deepseek-coder-v2"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"
export OPENAI_API_KEY="ollama"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
