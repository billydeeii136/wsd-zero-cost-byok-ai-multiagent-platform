#!/bin/bash
# META: {"id": "12", "slug": "llamacpp-server", "name": "llama.cpp Server", "tier": "local-free", "scope": "localhost", "model": "(GGUF model loaded at server start)", "desc": "Raw llama.cpp server for GGUF model inference"}
# llama.cpp Server (local-free)
# Raw llama.cpp server for GGUF model inference
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 12

export ZERO_COST_ACTIVE_MODE_ID="12"
export ZERO_COST_ACTIVE_MODE_SLUG="llamacpp-server"
export ZERO_COST_ACTIVE_MODE_NAME="llama.cpp Server"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="(GGUF model loaded at server start)"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:8080/v1"
export OPENAI_API_KEY="llamacpp"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
