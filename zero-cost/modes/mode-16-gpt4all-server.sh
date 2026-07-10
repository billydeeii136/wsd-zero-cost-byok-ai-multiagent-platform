#!/bin/bash
# META: {"id": "16", "slug": "gpt4all-server", "name": "GPT4All Server", "tier": "local-free", "scope": "localhost", "model": "(model loaded in GPT4All)", "desc": "GPT4All local API server"}
# GPT4All Server (local-free)
# GPT4All local API server
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 16

export ZERO_COST_ACTIVE_MODE_ID="16"
export ZERO_COST_ACTIVE_MODE_SLUG="gpt4all-server"
export ZERO_COST_ACTIVE_MODE_NAME="GPT4All Server"
export ZERO_COST_ACTIVE_MODE_TIER="local-free"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost"
export ZERO_COST_DEFAULT_MODEL="(model loaded in GPT4All)"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

export OPENAI_BASE_URL="http://127.0.0.1:4891/v1"
export OPENAI_API_KEY="gpt4all"
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=0

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
