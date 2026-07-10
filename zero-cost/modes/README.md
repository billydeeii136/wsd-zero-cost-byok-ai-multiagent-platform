# WARP_ZERO_COST Modes Catalog

30 selectable local/BYOK routing variants for the zero-cost profile system. Every mode keeps Warp credit usage at **zero** — modes only change which LLM backend your shell/tools point to (`OPENAI_BASE_URL`, `OPENAI_API_KEY`, `OLLAMA_HOST`, etc.).

## Usage

```bash
# List all 30 modes
~/.config/zero-cost/list-modes.sh

# Activate a mode by ID or slug (must be sourced to affect current shell)
source ~/.config/zero-cost/select-mode.sh 07
source ~/.config/zero-cost/select-mode.sh ollama-command-r

# The active mode persists automatically for all future shells via profile.sh
```

## Cost Tiers

- **local-free** — Self-hosted inference server on this machine or LAN. Genuinely $0 regardless of key.
- **byok-remote** — Direct provider API using your own key (from `~/.warp/byok-key-inventory.env`). Zero Warp credits; provider may bill your account per their own pricing/free tier.
- **hybrid** — Local-first, with an automatic BYOK fallback only if the local backend is unreachable.

## Full Catalog

| ID | Slug | Tier | Scope | Default Model | Description |
|----|------|------|-------|---------------|-------------|
| 01 | ollama-default | local-free | localhost | llama3.2 | Balanced general-purpose local model via Ollama |
| 02 | ollama-coder | local-free | localhost | qwen2.5-coder | Coding-focused local model (Qwen2.5-Coder) via Ollama |
| 03 | ollama-heavy-reasoning | local-free | localhost | mixtral | Larger mixture-of-experts model for heavier reasoning (Mixtral) |
| 04 | ollama-lightweight | local-free | localhost | phi3 | Small/fast model for low-power hardware (Phi-3) |
| 05 | ollama-deepseek-coder | local-free | localhost | deepseek-coder-v2 | DeepSeek Coder V2 local model |
| 06 | ollama-gemma | local-free | localhost | gemma2 | Google Gemma 2 local model via Ollama |
| 07 | ollama-command-r | local-free | localhost | command-r | Command-R, strong for RAG and tool-use workflows |
| 08 | ollama-starcoder | local-free | localhost | starcoder2 | StarCoder2 code completion model |
| 09 | ollama-llama-vision | local-free | localhost | llama3.2-vision | Multimodal vision-capable local model |
| 10 | ollama-mistral | local-free | localhost | mistral | Mistral 7B general-purpose local model |
| 11 | lmstudio-local | local-free | localhost | (LM Studio GUI) | LM Studio local server, GUI-managed model selection |
| 12 | llamacpp-server | local-free | localhost | (GGUF loaded) | Raw llama.cpp server for GGUF model inference |
| 13 | textgen-webui | local-free | localhost | (WebUI loaded) | oobabooga text-generation-webui OpenAI-compatible API |
| 14 | koboldcpp | local-free | localhost | (KoboldCPP loaded) | KoboldCPP local inference server |
| 15 | localai | local-free | localhost | (LocalAI configured) | LocalAI self-hosted OpenAI-compatible server |
| 16 | gpt4all-server | local-free | localhost | (GPT4All loaded) | GPT4All local API server |
| 17 | jan-ai-server | local-free | localhost | (Jan loaded) | Jan.ai local server, OpenAI-compatible |
| 18 | vllm-server | local-free | localhost | (vLLM configured) | vLLM high-throughput local inference server |
| 19 | ollama-lan-wide | local-free | lan | llama3.2 | Ollama bound to 0.0.0.0, reachable by other WSD home network nodes |
| 20 | ollama-airgapped-strict | local-free | localhost-strict | llama3.2 | Strict loopback-only; remote BYOK explicitly disabled at the mode level |
| 21 | openrouter-byok | byok-remote | remote | llama-3.1-70b-instruct | OpenRouter multi-provider model gateway |
| 22 | groq-byok | byok-remote | remote | llama-3.3-70b-versatile | Groq ultra-fast inference, generous free tier |
| 23 | together-byok | byok-remote | remote | Llama-3-70b-chat-hf | Together.ai hosted open-weight models |
| 24 | fireworks-byok | byok-remote | remote | llama-v3p1-70b-instruct | Fireworks.ai hosted inference |
| 25 | mistral-byok | byok-remote | remote | mistral-large-latest | Mistral's own hosted API |
| 26 | deepinfra-byok | byok-remote | remote | Meta-Llama-3.1-70B-Instruct | DeepInfra hosted open-weight models |
| 27 | perplexity-byok | byok-remote | remote | llama-3.1-sonar-large-128k-online | Perplexity API with live web-grounded answers |
| 28 | anyscale-byok | byok-remote | remote | Meta-Llama-3-70B-Instruct | Anyscale Endpoints hosted inference |
| 29 | azure-openai-byok | byok-remote | remote | (Azure deployment) | Azure OpenAI enterprise BYOK routing |
| 30 | hybrid-failover | hybrid | localhost+remote | llama3.2 | Local Ollama first; auto-fails over to OpenRouter BYOK only if local server is unreachable |

## Related Zero-Cost Projects (Kept Separate — Not Duplicated Here)

These are independent zero-cost efforts elsewhere on this machine. They are **not renamed, merged, or duplicated** into the WARP_ZERO_COST modes above — each keeps its own identity, scope, and naming.

| Project | Location | What it actually is |
|---|---|---|
| WSD-Zero-Cost-AI | `~/warp_ready_projects/WSD-Zero-Cost-AI` | Android (A15/A16/A17) Termux client that talks to a Mac-hosted local Ollama/AI gateway over the home LAN, with bearer-token auth and a DNS routing plan. Own naming: `WSD_PHONE_ZERO_COST_AI`. |
| wsd_ccos_ai_lab BYOK profile | `~/wsd_ccos_ai_lab/.env.zero_cost` | A separate BYOK env template (`BYOK_ZERO_COST_MODE=true`, `OPENAI_HARD_DISABLE=true`) defaulting to local Ollama (`qwen2.5:0.5b`). Has its own git repo. |
| free-llm-api-resources | `~/free-llm-api-resources` | A maintained, auto-generated catalog of genuinely free LLM API tiers (OpenRouter free models, Google AI Studio, Groq, Cerebras, HuggingFace, GitHub Models, Cloudflare Workers AI) with real, sourced rate limits. |

Verified as functional/legitimate zero-cost resources. None were modified by this repo.

### Flagged: not verified as factual zero-cost

| Project | Location | Issue |
|---|---|---|
| FREE-openai-api-keys | `~/FREE-openai-api-keys` | The listed "keys" (e.g. `sk-abcdef1234567890...`) are placeholder patterns, not real OpenAI keys. They will not authenticate. Not a functional resource. |
| free-1000-tb-cloud-cluster-mesh | `~/wsd_repos/free-1000-tb-cloud-cluster-mesh` | Empty scaffold repo (README: "(TODO: Add description)"). No provider offers anywhere near 1000TB free; the claim is currently unsubstantiated and unimplemented. |

## Notes

- **BYOK remote modes (21-29, 30 fallback)** read their API key from an environment variable (e.g. `OPENROUTER_API_KEY`, `GROQ_API_KEY`) that should be defined in `~/.warp/byok-key-inventory.env`. If the variable is unset, the mode still activates but prints a warning to stderr — it will not silently use Warp credits instead.
- **Mode 19 (ollama-lan-wide)** only changes where *clients* connect. To actually bind the Ollama server itself to the LAN, start it with `OLLAMA_HOST=0.0.0.0:11434 ollama serve`.
- **Mode 30 (hybrid-failover)** performs a live 1-second `curl` health check against local Ollama on activation; if unreachable it switches to OpenRouter BYOK automatically.
- Every mode sets `ZERO_COST_WARP_CREDIT_FALLBACK=0` — this is a fixed, non-configurable invariant across all 30 modes, independent of which LLM backend is selected.
- Modes never modify `~/.warp/settings.toml`; that file's zero-credit enforcement is handled separately and globally by `warp-guard.sh`.
