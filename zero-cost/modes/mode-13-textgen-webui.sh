#!/bin/bash
# META: {"id": "13", "slug": "textgen-webui", "name": "Text Generation WebUI", "tier": "local-free", "scope": "localhost", "model": "(model loaded in WebUI)", "desc": "oobabooga text-generation-webui OpenAI-compatible API"}
# Text Generation WebUI (local-free)
# oobabooga text-generation-webui OpenAI-compatible API
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 13

export ZERO_COST_ACTIVE_MODE_ID="13"
export ZERO_COST_ACTIVE_MODE_SLUG="textgen-webui"
export ZERO_COST_ACTIVE_MODE_NAME="Text Generation WebUI"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="(model loaded in WebUI)"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:5000/v1"
export OPENAI_API_KEY="textgen"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
