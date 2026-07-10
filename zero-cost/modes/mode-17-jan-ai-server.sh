#!/bin/bash
# META: {"id": "17", "slug": "jan-ai-server", "name": "Jan.ai Local Server", "tier": "local-free", "scope": "localhost", "model": "(model loaded in Jan)", "desc": "Jan.ai local server, OpenAI-compatible"}
# Jan.ai Local Server (local-free)
# Jan.ai local server, OpenAI-compatible
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 17

export ZERO_COST_ACTIVE_MODE_ID="17"
export ZERO_COST_ACTIVE_MODE_SLUG="jan-ai-server"
export ZERO_COST_ACTIVE_MODE_NAME="Jan.ai Local Server"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="(model loaded in Jan)"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:1337/v1"
export OPENAI_API_KEY="jan-ai"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
