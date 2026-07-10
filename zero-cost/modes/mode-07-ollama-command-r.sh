#!/bin/bash
# META: {"id": "07", "slug": "ollama-command-r", "name": "Ollama Command-R", "tier": "local-free", "scope": "localhost", "model": "command-r", "desc": "Command-R, strong for RAG and tool-use workflows"}
# Ollama Command-R (local-free)
# Command-R, strong for RAG and tool-use workflows
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 07

export ZERO_COST_ACTIVE_MODE_ID="07"
export ZERO_COST_ACTIVE_MODE_SLUG="ollama-command-r"
export ZERO_COST_ACTIVE_MODE_NAME="Ollama Command-R"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="command-r"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"
export OPENAI_API_KEY="ollama"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
