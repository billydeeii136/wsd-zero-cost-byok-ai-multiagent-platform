#!/bin/bash
# META: {"id": "30", "slug": "hybrid-failover", "name": "Hybrid Local-First Failover", "tier": "hybrid", "scope": "localhost+remote", "model": "llama3.2", "desc": "Local Ollama first; auto-fails over to OpenRouter BYOK only if local server is unreachable"}
# Hybrid Local-First Failover (hybrid)
# Local Ollama first; auto-fails over to OpenRouter BYOK only if local server is unreachable
# Activate with: source "$HOME/.config/zero-cost/select-mode.sh" 30

export ZERO_COST_ACTIVE_MODE_ID="30"
export ZERO_COST_ACTIVE_MODE_SLUG="hybrid-failover"
export ZERO_COST_ACTIVE_MODE_NAME="Hybrid Local-First Failover"
export ZERO_COST_ACTIVE_MODE_TIER="hybrid"
export ZERO_COST_ACTIVE_MODE_SCOPE="localhost+remote"
export ZERO_COST_DEFAULT_MODEL="llama3.2"
export ZERO_COST_WARP_CREDIT_FALLBACK=0  # always off: no mode may spend Warp credits

# Hybrid mode: probe local Ollama; fail over to OpenRouter BYOK only if unreachable.
if command -v curl >/dev/null 2>&1 && curl -s -o /dev/null -m 1 "http://127.0.0.1:11434/api/tags"; then
    export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"
    export OPENAI_API_KEY="ollama"
    export ZERO_COST_HYBRID_ACTIVE_BACKEND="local-ollama"
else
    export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
    export OPENAI_API_KEY="${OPENROUTER_API_KEY:-}"
    export ZERO_COST_HYBRID_ACTIVE_BACKEND="openrouter-byok"
    if [ -z "$OPENAI_API_KEY" ]; then
        printf '[zero-cost] Warning: local Ollama unreachable and OPENROUTER_API_KEY is not set.\n' >&2
    fi
fi
export ZERO_COST_ALLOW_REMOTE_OPENAI_COMPAT=1

export OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"
export LLM_BASE_URL="$OPENAI_BASE_URL"
export LLM_API_KEY="$OPENAI_API_KEY"

printf '[zero-cost] Active mode: %s (%s)\n' "$ZERO_COST_ACTIVE_MODE_NAME" "$ZERO_COST_ACTIVE_MODE_TIER"
